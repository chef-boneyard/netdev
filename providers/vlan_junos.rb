#
# Cookbook Name:: netdev
# Provider:: vlan_junos
#
# Author:: Seth Chisamore <schisamo@opscode.com>
#
# Copyright 2013 Opscode, Inc.
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

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  updated_values = junos_client.updated_changed_properties(new_resource.state,
                                                           current_resource.state)
  unless updated_values.empty?
    message  = "create vlan #{new_resource.name} with values:"
    message << " #{updated_values.map{|e| e.join(" => ")}.join(", ")}"
    converge_by(message) do
      junos_client.write!
    end
  end
end

action :delete do
  if current_resource.exists?
    converge_by("delete existing vlan #{new_resource.name}") do
      junos_client.delete!
    end
  end
end

action :enable do
  if current_resource.exists? && !current_resource.active?
    converge_by("enable vlan #{new_resource.name}") do
      junos_client.activate!
    end
  end
end

action :disable do
  if current_resource.exists? && current_resource.active?
    converge_by("disable vlan #{new_resource.name}") do
      junos_client.deactivate!
    end
  end
end

def load_current_resource
  Chef::Log.info "Loading current resource #{new_resource.name}"

  @current_resource = Chef::Resource::NetdevVlan.new(new_resource.name)

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

private

def junos_client
  @junos_client ||= Netdev::JunosApiClient::Vlans.new(new_resource.name)
end
