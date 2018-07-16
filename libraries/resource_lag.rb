#
# Cookbook Name:: netdev
# Resource:: lag
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
  class Resource::NetdevLinkAggregationGroup < Resource
    provides      :netdev_lag
    identity_attr :lag_name
    state_attrs   :links, :minimum_links, :lacp

    attr_accessor :active, :exists
    alias active? active
    alias exists? exists

    def initialize(name, run_context = nil)
      super

      @resource_name = :netdev_lag

      # Set default actions and allowed actions
      @action = :create
      @allowed_actions.push(:create, :delete)

      # Set the name attribute and default attributes
      @lag_name = name
      @lacp     = 'disable'

      # State attributes that are set by the provider
      @exists   = false
    end

    #
    # The name of the link aggregation group.
    #
    # @param [String] arg
    # @return [String]
    #
    def lag_name(arg = nil)
      set_or_return(:lag_name, arg, kind_of: String)
    end

    #
    # An array of interfaces to be configured as members of the link
    # aggregation group.
    #
    # @param [String] arg
    # @return [String]
    #
    def links(arg = nil)
      set_or_return(:links, arg, kind_of: Array)
    end

    #
    # The minimum number of physical links that are required to ensure the
    # availability of the link aggregation group.
    #
    # @param [String] arg
    # @return [String]
    #
    def minimum_links(arg = nil)
      set_or_return(:minimum_links, arg, kind_of: Integer)
    end

    #
    # The link aggregation control protocol mode. Possible values: active
    # (active mode), disable (not used), or passive (passive mode).
    #
    # @param [String] arg
    # @return [String]
    #
    def lacp(arg = nil)
      set_or_return(
        :lacp,
        arg,
        kind_of: String,
        equal_to: %w[disable active passive]
      )
    end
  end
end

class Chef::Provider::NetdevLinkAggregationGroup; end
