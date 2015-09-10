#
# Cookbook Name:: netdev
# Provider:: vlan
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

require 'chef/resource'
require 'chef/provider'

require_relative '_helper'
require_relative '_junos_api_client'
require_relative 'resource_vlan'

class Chef
  class Provider::NetdevVirtualLAN::Junos < Provider
    include Netdev::Helper

    #
    # This provider supports why-run mode.
    #
    def whyrun_supported?
      true
    end

    def load_current_resource
      @current_resource = Chef::Resource::NetdevVirtualLAN.new(new_resource.name)
      @current_resource.vlan_name(new_resource.vlan_name)

      # We want to override the default description generated for this
      # resource. Hacky workaround for the fact Chef::Resource#set_or_return
      # won't let us nil out an attribute.
      @current_resource.instance_variable_set('@description', nil)

      if (vlan = junos_client.managed_resource) && vlan.exists?
        @current_resource.vlan_id(vlan[:vlan_id])
        @current_resource.description(vlan[:description])
        @current_resource.active = vlan[:_active]
        @current_resource.exists = true
      else
        # Validation forces us to set something here
        @current_resource.vlan_id(-1)
        @current_resource.active = false
        @current_resource.exists = false
      end
      @current_resource
    end

    #
    # Create the given interface.
    #
    def action_create
      updated_values = junos_client.updated_changed_properties(new_resource.state,
                                                               current_resource.state)
      unless updated_values.empty?
        message = "create vlan #{new_resource.name} with values:"
        message << " #{pretty_print_updated_values(updated_values)}"
        converge_by(message) do
          junos_client.write!
        end
      end
    end

    #
    # Delete the given interface.
    #
    def action_delete
      if current_resource.exists?
        converge_by("delete existing vlan #{new_resource.name}") do
          junos_client.delete!
        end
      end
    end

    private

    def junos_client
      @junos_client ||= Netdev::Junos::ApiClient::Vlans.new(new_resource.vlan_name)
    end
  end
end
