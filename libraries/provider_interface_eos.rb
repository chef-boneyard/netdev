#
# Cookbook Name:: netdev
# Provider:: interface
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
require_relative 'resource_interface'

class Chef
  class Provider::NetdevInterface::EOS < Provider
    include Netdev::Helper

    #
    # This provider supports why-run mode.
    #
    def whyrun_supported?
      true
    end

    def load_current_resource
      @current_resource = Chef::Resource::NetdevInterface.new(@new_resource.name)
      @current_resource.interface_name(@new_resource.interface_name)
      @current_resource.exists = false

      if interface
        @current_resource.enable(interface['admin'])
        @current_resource.description(interface['description'])
        @current_resource.mtu(interface['mtu'])
        @current_resource.speed(interface['speed'])
        @current_resource.duplex(interface['duplex'])
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
        converge_by("create interface #{new_resource.name}") do
          # convert `--enable` into `--admin`
          opts = opts.map do |v|
            if v =~ /--enable/
              "--admin #{new_resource.enable}"
            else
              v
            end
          end
          command = "netdev interface edit #{new_resource.interface_name}"
          command << opts.join(' ')
          execute_command(command)
        end
      end
    end

    #
    # Delete the given interface.
    #
    def action_delete
      if current_resource.exists?
        converge_by("remove interface #{new_resource.name}") do
          execute_command "netdev interface delete #{new_resource.interface_name}"
        end
      end
    end

    private

    def interface
      @interface ||= begin
        output = execute_command('netdev interface list --output ruby-hash')
        output['result'][new_resource.interface_name]
      end
    end
  end
end
