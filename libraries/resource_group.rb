#
# Cookbook Name:: netdev
# Resource:: JUNOS apply group
#
# Copyright 2014, Chef Software, Inc.
# Copyright 2015, Juniper Network.
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
  class Resource::NetdevGroup < Resource
    provides      :netdev_group
    identity_attr :group_name
    state_attrs   :template_path, :variables

    attr_accessor :exists
    alias_method  :exists?, :exists

    def initialize(name, run_context = nil)
      super

      @resource_name = :netdev_group

      # Set default actions and allowed actions
      @action = :create
      @allowed_actions.push(:create, :delete)

      # Set the name attribute and default attributes
      @group_name      = name

      @enable          = true

      # State attributes that are set by the provider
      @exists          = false
    end

    #
    # The name of the JUNOS Group.
    #
    # @param [String] arg
    # @return [String]
    #
    def group_name(arg = nil)
      set_or_return(:group_name, arg, kind_of: String)
    end

    #
    # The variables to template.
    #
    # @param [HASH] arg
    # @return [HASH]
    #
    def variables(args = nil)
      set_or_return(
        :variables,
        args,
        kind_of: [Hash]
      )
    end

    #
    # The JUNOS configuration template path.
    #
    # @param [String] arg
    # @return [String]
    #
    def template_path(arg = nil)
      set_or_return(
        :template_path,
        arg,
        kind_of: String
      )
    end
  end
end
class Chef::Provider::NetdevGroup; end
