#
# Cookbook:: netdev
# Provider:: lag
#
# Copyright:: 2013, Arista Networks
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
require_relative 'resource_lag'

class Chef
  class Provider::NetdevLinkAggregationGroup::EOS < Provider
    include Netdev::Helper

    #
    # This provider supports why-run mode.
    #

    def load_current_resource
      @current_resource = Chef::Resource::NetdevLinkAggregationGroup.new(new_resource.name)
      @current_resource.lag_name(new_resource.lag_name)
      @current_resource.exists = false

      if lag
        @current_resource.links(lag['links'])
        @current_resource.minimum_links(lag['minimum_links'])
        @current_resource.lacp(lag['lacp'])
        @current_resource.exists = true
      end
      @current_resource
    end

    #
    # Create the given link aggregation group.
    #
    def action_create
      opts = generate_command_opts
      if opts.any?
        if current_resource.exists?
          converge_by("edit lag #{new_resource.name} will be modified") do
            command = "netdev lag edit #{new_resource.lag_name} "
            command << opts.join(' ')
            execute_command(command)
          end
        else
          converge_by("create lag #{new_resource.name}") do
            command = "netdev lag create #{new_resource.lag_name} "
            command << opts.join(' ')
            execute_command(command)
          end
        end
      end
    end

    #
    # Delete the given link aggregation group.
    #
    def action_delete
      if current_resource.exists?
        converge_by("remove lag #{current_resource.name}") do
          execute 'netdev lag delete' do
            command "netdev lag delete #{new_resource.lag_name}"
            execute_command(command)
          end
        end
      end
    end

    private

    def lag
      @lag ||= begin
        output = execute_command('netdev lag list --output ruby-hash')
        output['result'][new_resource.lag_name]
      end
    end
  end
end
