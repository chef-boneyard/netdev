#
# Cookbook Name:: netdev
# Provider:: vlan
#
# Copyright 2013, Arista Networks
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
require_relative 'resource_vlan'

class Chef
  class Provider::NetdevVirtualLAN::EOS < Provider
    include Netdev::Helper

    #
    # This provider supports why-run mode.
    #
    def whyrun_supported?
      true
    end

    def load_current_resource
      @current_resource = Chef::Resource::NetdevVirtualLAN.new(new_resource.name)
      @current_resource.vlan_id(@new_resource.vlan_id)
      @current_resource.exists = false

      if vlan
        @current_resource.vlan_name(vlan['vlan_name'])
        @current_resource.exists = true
      end
      @current_resource
    end

    #
    # Create the given interface.
    #
    def action_create
      if updated?(current_resource.vlan_name, new_resource.vlan_name)
        if current_resource.exists?
          converge_by("edit vlan #{new_resource.name} will be modified") do
            command = "netdev vlan edit #{new_resource.vlan_id}"
            command << " --name #{new_resource.vlan_name}"
            execute_command(command)
          end
        else
          converge_by("Vlan #{new_resource.name} will be created") do
            command = "netdev vlan create #{new_resource.vlan_id}"
            command << " --name #{new_resource.vlan_name}"
            execute_command(command)
          end
        end
      end
    end

    #
    # Delete the given interface.
    #
    def action_delete
      if @current_resource.exists
        converge_by("remove vlan #{current_resource.name}") do
          execute_command "netdev vlan delete #{new_resource.vlan_id}"
        end
      else
        Chef::Log.info("Vlan doesn't exist, nothing to delete")
      end
    end

    private

    def vlan
      @vlan ||= begin
        output = execute_command('netdev vlan list --output ruby-hash')
        output['result'][new_resource.vlan_id]
      end
    end
  end
end
