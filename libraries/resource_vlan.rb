#
# Cookbook Name:: netdev
# Resource:: vlan
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
  class Resource::NetdevVirtualLAN < Resource
    provides      :netdev_vlan
    identity_attr :vlan_name
    state_attrs   :vlan_id, :description

    attr_accessor :active, :exists
    alias_method  :active?, :active
    alias_method  :exists?, :exists

    def initialize(name, run_context = nil)
      super

      @resource_name = :netdev_vlan

      # Set default actions and allowed actions
      @action = :create
      @allowed_actions.push(:create, :delete)

      # Set the name attribute and default attributes
      @vlan_name   = name
      @description = "Chef created vlan: #{name}"

      # State attributes that are set by the provider
      @exists    = false
    end

    #
    # The name of the virtual LAN.
    #
    # @param [String] arg
    # @return [String]
    #
    def vlan_name(arg = nil)
      set_or_return(:vlan_name, arg, kind_of: String)
    end

    #
    # The description of the virtual LAN.
    #
    # @param [String] arg
    # @return [String]
    #
    def description(arg = nil)
      set_or_return(:description, arg, kind_of: String)
    end

    #
    # The identifier for the virtual LAN.
    #
    # @param [String] arg
    # @return [String]
    #
    def vlan_id(arg = nil)
      set_or_return(:vlan_id, arg, kind_of: Integer)
    end
  end
end

class Chef::Provider::NetdevVirtualLAN; end
