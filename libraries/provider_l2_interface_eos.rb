#
# Cookbook Name:: netdev
# Provider:: l2_interface
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
require_relative 'resource_l2_interface'

class Chef
  class Provider::NetdevL2Interface::EOS < Provider
    include Netdev::Helper

    #
    # This provider supports why-run mode.
    #
    def whyrun_supported?
      true
    end

    def load_current_resource
      @current_resource = Chef::Resource::NetdevL2Interface.new(new_resource.name)
      @current_resource.l2_interface_name(new_resource.l2_interface_name)
      @current_resource.exists = false

      if l2_interface
        @current_resource.description(l2_interface['description'])
        @current_resource.untagged_vlan(l2_interface['untagged_vlan'])
        @current_resource.tagged_vlans(l2_interface['tagged_vlans'])
        @current_resource.vlan_tagging(l2_interface['vlan_tagging'])
        @current_resource.exists = true
      end
      @current_resource
    end

    #
    # Create the given interface.
    #
    def action_create
      opts = generate_command_opts
      if opts.any?
        if current_resource.exists?
          converge_by("edit l2interface #{new_resource.name} will be modified") do
            command  = "netdev l2interface edit #{new_resource.l2_interface_name} "
            command << opts.join(' ')
            execute_command(command)
          end
        else
          converge_by("L2interface #{new_resource.name} will be created") do
            command  = "netdev l2interface create #{new_resource.l2_interface_name} "
            command << opts.join(' ')
            execute_command(command)
          end
        end
      end
    end

    #
    # Delete the given interface.
    #
    def action_delete
      if current_resource.exists?
        converge_by("remove l2interface #{current_resource.name}") do
          command = "netdev l2interface delete #{new_resource.l2_interface_name}"
          execute_command(command)
        end
      end
    end

    private

    def l2_interface
      @l2_interface ||= begin
        output = execute_command('netdev l2interface list --output ruby-hash')
        output['result'][new_resource.l2_interface_name]
      end
    end
  end
end

Chef::Platform.set(
  platform: :eos,
  resource: :netdev_l2_interface,
  provider: Chef::Provider::NetdevL2Interface::EOS
)
