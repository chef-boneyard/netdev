#
# Author:: Seth Chisamore <schisamo@opscode.com>
#
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
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

module Netdev
  module Resource
    # Common methods shared by all netdev_* resources.
    module Common

      attr_accessor :active, :exists
      alias_method :active?, :active
      alias_method :exists?, :exists

      # Override intializer and replace with a version that performs
      # late binding of a provider based on node platform.
      def initialize(name, run_context = nil)
        super

        platform = begin
          # We need to update core Ohai to properly identify EOS
          if File.exist?('/etc/Eos-release')
            'eos'
          # It is entirely possible we will not have a node object. This
          # happens when a resource is instantiated in a provider's
          # `#load_current_resource` method.
          elsif node
            node['platform']
          end
        end

        if platform
          @provider = platform_provider_for_resource(self.class.resource_name,
                                                     platform)
        end
      end

      # Supported Networking Operating Systems:
      #
      # junos / Juniper / http://en.wikipedia.org/wiki/Junos
      # eos / Arista / http://en.wikipedia.org/wiki/Extensible_Operating_System#Extensible_Operating_System
      #
      KNOWN_PLATFORMS = %w{
        eos
        junos
      }

      # Given a resource name attempts to locate a provider based on
      # platform name. This all relies on convention.
      #
      # For example given a resource named `netdev_interface` and a
      # platform of `junos` the following provider should be returned:
      #
      #   Chef::Provider::NetdevInterfaceJunos
      #
      def platform_provider_for_resource(resource_name, platform)

        # Raise a nice exception if a non-supported platform is
        # passed in.
        unless KNOWN_PLATFORMS.include?(platform)
          error_message  = "The platform '#{platform}' is not currently supported"
          error_message << " by the '#{resource_name}' resource."
          error_message << ' Supported platforms include: '
          error_message << KNOWN_PLATFORMS.join(', ')
          raise error_message
        end

        provider_name = "#{resource_name}_#{platform}"
        # #convert_to_class_name comes from the base `Chef::Resource`
        # class.
        provider_class_name = convert_to_class_name(provider_name)
        provider_class = nil

        log_message  = "plaform-specific provider #{provider_name} defined in"
        log_message << " Chef::Provider::#{provider_class_name} for"
        log_message << " #{resource_name} resource"

        begin

          provider_class = Chef::Provider.const_get(provider_class_name)
          Chef::Log.debug("#{self.class.to_s}: using #{log_message}")

        rescue NameError
          Chef::Log.warn("#{self.class.to_s}: could not load #{log_message}")
        end

        provider_class
      end
    end
  end
end
