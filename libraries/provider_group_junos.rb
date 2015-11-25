#
# Cookbook Name:: netdev
# Provider:: group
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
require_relative 'resource_group'

class Chef
  class Provider::NetdevGroup::Junos < Provider
    include Netdev::Helper

    #
    # This provider supports why-run mode.
    #
    def whyrun_supported?
      true
    end

    def load_current_resource 
      @current_resource = Chef::Resource::NetdevGroup.new(new_resource.name)
      @current_resource.group_name(new_resource.group_name)

      if (group = junos_client.managed_resource) && group.exists?
        @current_resource.exists = true
      else
        @current_resource.exists = false
      end
      
      @file_path = "/var/tmp/#{new_resource.name}"
      @new_values = new_resource.state
      @current_values = current_resource.state

      @template_resource = Chef::Resource::Template.new(@file_path, run_context)
      @template_resource.source (@new_values[:template_path]) 
      @template_resource.cookbook (new_resource.cookbook_name)
      @template_resource.variables (@new_values[:variables])
      @template_resource.run_action( @action )
      @is_resource_updated =  @template_resource.updated_by_last_action?
      @current_resource
    end

    #
    # Create the given group.
    #
    def action_create
      unless @is_resource_updated or not @current_resource.exists
	Chef::Log.info("Configuration file is same. Nothing to commit.")
        return
      end
      @new_values[:path] = @file_path
      format = (@new_values[:template_path].split('/'))[-1].split('.') 
      if format[1] != 'erb' 
        @new_values[:format] = format[1]
      else
	@new_values[:format] = 'xml'  
      end

      @new_values.delete(:template_path)
      @current_values.delete(:template_path)
      @new_values.delete(:variables)
      @current_values.delete(:variables)
      updated_values = junos_client.updated_changed_properties(@new_values,
                                                               @current_values)
      unless updated_values.empty?
        message  = "create JUNOS group #{new_resource.name} and apply it."
        converge_by(message) do
          junos_client.write!
        end
      end
    end

    #
    # Delete the given group.
    #
    def action_delete
      if current_resource.exists?
        converge_by("delete JUNOS group #{new_resource.name}") do
          junos_client.delete!
        end
      end
    end

    private

    def junos_client
      @junos_client ||= Netdev::Junos::ApiClient::Group.new(new_resource.group_name)
    end
  end
end
