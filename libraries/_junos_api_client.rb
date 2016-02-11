#
# Copyright 2014, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

begin
  require 'junos-ez/stdlib'
  require 'net/netconf/exception'
rescue LoadError
  msg  = 'Could not load the junos-ez-stdlib gem...'
  msg << 'ensure you are using the Chef for Junos packages'
  Chef::Log.debug msg
end

module Netdev
  module Junos
    # Provides compatibility shim between netdev_*_junos
    # providers and the `junos-ez-stdlib` library.
    class ApiClient
      begin
        # All possible resources `junos-ez-stdlib`
        # is able to manage. This Hash is used for
        # validation and metaprogramming.
        KNOWN_RESOURCES = {
          :l1_ports => ::Junos::Ez::L1ports,
          :l2_ports => ::Junos::Ez::L2ports,
          :ip_ports => ::Junos::Ez::IPports,
          :vlans => ::Junos::Ez::Vlans,
          :lag_ports => ::Junos::Ez::LAGports,
          :group => ::Junos::Ez::Group
        }

        KNOWN_RESOURCES.each_pair do |resource, provider_module|

          # Create a child class for each logical resource type. This forces
          # us to be explicit on which type of resource to manage.
          c = Class.new(self)
          c.class_eval <<-EVAL
            def initialize(resource_name)
              super(:#{resource}, resource_name)
            end
          EVAL

          class_name = provider_module.to_s.split('::').last
          const_set class_name, c
        end
      rescue NameError
        # If the requires above didn't work our class
        # references are definitely not going to work!
        Chef::Log.debug 'Could not generate Netdev::Junos::ApiClient child classes.'
      end

      # The `Junos::Ez` providers expect certain values
      # to be symbolized or requests will fail.
      VALUES_TO_SYMBOLIZE = %w( auto up down half full active passive disabled )

      attr_reader :resource_type
      attr_reader :resource_name

      def initialize(resource_type, resource_name)
        unless KNOWN_RESOURCES.keys.include?(resource_type)
          error_message  = "Invalid resource type :#{resource_type}."
          error_message << " Try one of: :#{KNOWN_RESOURCES.keys.join(", :")}"
          fail error_message
        end

        @resource_type = resource_type
        @resource_name = resource_name
      end

      # Writes managed resource to the candidate configuration.
      def write!
        with_config_check do
          managed_resource.write!
          Chef::Log.debug("#{self} wrote managed resource to Junos candidate configuration")
        end
      end

      # Removes managed resource from the candidate configuration.
      def delete!
        with_config_check do
          managed_resource.delete!
          Chef::Log.debug("#{self} deleted managed resource from Junos candidate configuration")
        end
      end

      # Activate managed resource in candidate configuration.
      def activate!
        with_config_check do
          managed_resource.activate!
          Chef::Log.debug("#{self} activated managed resource in Junos candidate configuration")
        end
      end

      # Deactivate managed resource in candidate configuration.
      def deactivate!
        with_config_check do
          managed_resource.deactivate!
          Chef::Log.debug("#{self} deactivated managed resource in Junos candidate configuration")
        end
      end

      # Given a hash of new property values and old property values
      # determines which have changed. `nil` values are ignored.
      #
      # @param new_values [#Hash<Symbol, Object>]
      # @param current_values [#Hash<Symbol, Object>]
      #
      # @return [#Hash<Symbol, Object>] updated properties
      def updated_changed_properties(new_values, current_values)
        new_values.each_pair do |property_name, new_value|
          old_value = current_values[property_name]

          if !new_value.nil? && (old_value != new_value)
            Chef::Log.debug("#{self} property '#{property_name}' has changed to '#{new_value}'")

            if managed_resource.properties.include?(property_name)
              # junos-ez-stdlib prefers some values as symbols
              managed_resource[property_name] = if VALUES_TO_SYMBOLIZE.include?(new_value)
                                                  new_value.to_sym
                                                else
                                                  new_value
                                                end
            else
              error_message  = "#{self} don't know how to manage property :#{property_name}."
              error_message << " Known properties include: :#{managed_resource.properties.join(", :")}"
              fail ArgumentError, error_message
            end
          end
        end
        # return Hash of updated properties
        managed_resource.should
      end

      def managed_resource
        @managed_resource ||= begin
          transport.send(resource_type)[resource_name]
        rescue Netconf::RpcError => e
          Chef::Log.debug("Managed Resource #{resource_name} not found: #{e}")
          nil
        end
      end

      def to_s
        "#{self.class}[#{resource_name}]"
      end

      protected

      def transport
        Junos::ApiTransport.instance
      end

      # If processing the block of code passed in is successful config
      # changes are automatically committed. If something goes wrong
      # changes are rolled back.

      # Validates the Junos candidate configuration after yielding to
      # the code passed to this method. If validation fails an exception
      # is raised so the Chef run is halted.
      def with_config_check(&block)
        # ensure a transaction has been opened
        transport.start_transaction! unless transport.transaction_open?
        Netconf::raise_on_warning = true

        yield

        # validate the candidate configuration
        if transport.commit?
          Chef::Log.debug("#{self} validated Junos candidate configuration")
        end
      rescue Netconf::RpcError => e
        if rpc_errs = e.rsp.xpath('//rpc-error')
          all_count = rpc_errs.count
          warn_count = rpc_errs.xpath('error-severity').select{|err| err.text == 'warning'}.count
          if all_count - warn_count > 0
            Chef::Log.error("#{self} error communicating with the Junos XML API...rolling back!")
            Chef::Log.error(format_rpc_error(e))
            raise e
          elsif warn_count
            Chef::Log.info(format_rpc_error(e))
          end
        end

      end

      # Takes a `Netconf::RpcError` and extracts the request and response
      # XML and attempts to pretty format them using `nokogiri`. Although
      # this client does not have an explicit dependency on `nokogiri` it
      # should be available in the local Rubygem install as `junos-ez-stdlib`
      # does have a transitive dependency on `nokogiri`.
      #
      # @param rpc_error [Netconf::RpcError] the exception to format
      #
      def format_rpc_error(rpc_error)
        request = rpc_error.cmd
        response = rpc_error.rsp

        # attempt to pretty format the XML using Nokogiri. This library
        # should be available for our use as it is a depdency of the
        # `net-netconf` gem.
        begin
          require 'nokogiri'
          request = Nokogiri::XML(request.to_xml) { |doc| doc.noblanks }
          response = Nokogiri::XML(response.to_xml) { |doc| doc.noblanks }
        rescue LoadError
          Chef::Log.debug 'Could not load nokogiri gem, xml will not be formatted'
          # fall back to ugly xml
        end

        error_msg = <<-MSG

  JUNOS XML REQUEST:

  #{request.to_xml}

  JUNOS XML RESPONSE:

  #{response.to_xml}
        MSG

        error_msg
      end
    end
  end
end
