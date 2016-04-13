#
# Cookbook Name:: netdev
# Resource:: interface
#
# Copyright 2013, Arista Networks
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

require 'chef/resource'
require 'chef/provider'

class Chef
  class Resource::NetdevInterface < Resource
    provides      :netdev_interface
    identity_attr :interface_name
    state_attrs   :enable, :description, :mtu, :speed, :duplex

    attr_accessor :active, :exists
    alias_method  :active?, :active
    alias_method  :exists?, :exists

    def initialize(name, run_context = nil)
      super

      @resource_name = :netdev_interface

      # Set default actions and allowed actions
      @action = :create
      @allowed_actions.push(:create, :delete)

      # Set the name attribute and default attributes
      @interface_name  = name
      @description     = "Chef created interface: #{name}"
      @enable          = true
      @speed           = 'auto'
      @duplex          = 'auto'

      # State attributes that are set by the provider
      @exists = false
    end

    #
    # The name of the interface.
    #
    # @param [String] arg
    # @return [String]
    #
    def interface_name(arg = nil)
      set_or_return(:interface_name, arg, kind_of: String)
    end

    #
    # The description of the interface.
    #
    # @param [String] arg
    # @return [String]
    #
    def description(arg = nil)
      set_or_return(:description, arg, kind_of: String)
    end

    #
    # Indicates whether the interface is activated.
    #
    # @param [String] arg
    # @return [String]
    #
    def enable(arg = nil)
      set_or_return(:enable, arg, kind_of: [TrueClass, FalseClass])
    end

    #
    # The maximum transmission unit (MTU) for the network interface.
    #
    # @param [String] arg
    # @return [String]
    #
    def mtu(arg = nil)
      set_or_return(:mtu, arg, kind_of: Integer)
    end

    #
    # The speed for the interface.
    #
    # @param [String] arg
    # @return [String]
    #
    def speed(arg = nil)
      set_or_return(
        :speed,
        arg,
        kind_of: String,
        equal_to: %w( auto 100m 1g 10g 40g 56g 100g )
      )
    end

    #
    # The duplex mode for the interface.
    #
    # @param [String] arg
    # @return [String]
    #
    def duplex(arg = nil)
      set_or_return(
        :duplex,
        arg,
        kind_of: String,
        equal_to: %w( auto half full )
      )
    end
  end
end

class Chef::Provider::NetdevInterface; end
