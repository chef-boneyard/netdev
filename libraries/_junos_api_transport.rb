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

require 'forwardable'
require 'singleton'

require_relative '_junos_api_client'

begin
  require 'net/netconf/jnpr/ioproc'
  require 'junos-ez/stdlib'
rescue LoadError
  msg  = 'Could not load the junos-ez-stdlib gem...'
  msg << 'ensure you are using the Chef for Junos packages'
  Chef::Log.debug msg
end

module Netdev
  module Junos
    # Singleton class used to control Junos transaction lifecycle.
    class ApiTransport
      include Singleton
      extend Forwardable

      attr_accessor :connection_open
      attr_accessor :transaction_open
      alias_method  :transaction_open?, :transaction_open

      def_delegator :@transport, :[]

      begin
        ApiClient::KNOWN_RESOURCES.keys.each do |resource|
          def_delegator :@transport, resource.to_sym
        end
      rescue NameError
        Chef::Log.debug 'Could not load Netdev::Junos::ApiClient class'
      end

      def_delegator :@transport_config, :unlock!
      def_delegator :@transport_config, :commit?
      def_delegator :@transport_config, :commit!
      def_delegator :@transport_config, :rollback!

      # Creates a fully-initialized Netconf transport instance for
      # communicating with the Junos XML API. Currently we only support
      # the `IOProc` transport which means this client must be run from
      # the switch it is managing.
      def initialize
        open_connection!
        @transaction_open = false
      end

      def to_s
        self.class.to_s
      end

      def start_transaction!
        # Acquire an exclusive lock on the configuration
        @transport_config.lock!
        Chef::Log.info("#{self}: Acquired exclusive Junos configuration lock")
        @transaction_open = true
      end

      def commit_transaction!(commit_log_comment = nil)
        opts = {}
        opts[:comment] = commit_log_comment if commit_log_comment
        if @transaction_open
           # commit the candidate configuration
           @transport_config.commit!(opts)
           Chef::Log.info('Committed pending Junos candidate configuration changes')
           # release the exclusive lock on the configuration
           @transport_config.unlock!
           Chef::Log.info('Released exclusive Junos configuration lock')
           @transaction_open = false
        else
           Chef::Log.debug("#{self}: Nothing to commit !! ")
        end
      end

      private

      def open_connection!
        # Create a connection to the NETCONF service
        @transport = Netconf::IOProc.new
        @transport.open

        # enable basic Junos EZ Stdlib providers
        ::Junos::Ez::Provider(@transport)
        ::Junos::Ez::Config::Utils(@transport, :config)
        @transport_config = @transport.config

        ApiClient::KNOWN_RESOURCES.each_pair do |resource, provider_module|
          provider_module.send(:Provider, @transport, resource)
        end
        @connection_open = true
      end
    end
  end
end
