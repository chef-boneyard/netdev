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
  class Resource::NetdevL2Interface < Resource
    provides      :netdev_l2_interface
    identity_attr :l2_interface_name
    state_attrs   :description, :untagged_vlan, :tagged_vlans, :vlan_tagging

    attr_accessor :active, :exists
    alias_method  :active?, :active
    alias_method  :exists?, :exists

    def initialize(name, run_context = nil)
      super

      @resource_name = :netdev_l2_interface

      # Set default actions and allowed actions
      @action = :create
      @allowed_actions.push(:create, :delete)

      # Set the name attribute and default attributes
      @l2_interface_name = name
      @description       = "Chef created layer 2 interface: #{name}"
      @vlan_tagging      = false

      # State attributes that are set by the provider
      @exists    = false
    end

    #
    # The name of the L2 interface.
    #
    # @param [String] arg
    # @return [String]
    #
    def l2_interface_name(arg = nil)
      set_or_return(:l2_interface_name, arg, kind_of: String)
    end

    #
    # The description of the L2 interface.
    #
    # @param [String] arg
    # @return [String]
    #
    def description(arg = nil)
      set_or_return(:description, arg, kind_of: String)
    end

    #
    # An array of VLANs that carry traffic on a trunk interface.
    #
    # @param [String] arg
    # @return [String]
    #
    def tagged_vlans(arg = nil)
      set_or_return(:tagged_vlans, arg, kind_of: Array)
    end

    #
    # The native VLAN on the L2 interface.
    #
    # @param [String] arg
    # @return [String]
    #
    def untagged_vlan(arg = nil)
      set_or_return(:untagged_vlan, arg, kind_of: String)
    end

    #
    # Indicates whether a port is in access or trunk mode.
    #
    # @param [String] arg
    # @return [String]
    #
    def vlan_tagging(arg = nil)
      set_or_return(:vlan_tagging, arg, kind_of: [TrueClass, FalseClass])
    end
  end
end

class Chef::Provider::NetdevL2Interface; end
