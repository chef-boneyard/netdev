#
# Cookbook Name:: netdev
# Provider:: l2_interface_junos
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

use_inline_resources

action :create do
  updated_values = junos_client.updated_changed_properties(new_resource.state,
                                                           current_resource.state)
  unless updated_values.empty?
    message  = "create layer 2 interface #{new_resource.name} with values:"
    message << " #{updated_values.map{|e| e.join(" => ")}.join(", ")}"
    converge_by(message) do
      junos_client.write!
    end
  end
end

action :delete do
  if current_resource.exists?
    converge_by("delete existing layer 2 interface #{new_resource.name}") do
      junos_client.delete!
    end
  end
end

def load_current_resource
  Chef::Log.info "Loading current resource #{new_resource.name}"

  @current_resource = Chef::Resource::NetdevL2Interface.new(new_resource.name)

  if (port = junos_client.managed_resource) && port.exists?
    @current_resource.description(port[:description])
    @current_resource.untagged_vlan(port[:untagged_vlan])
    @current_resource.tagged_vlans(port[:tagged_vlans].to_a)
    @current_resource.vlan_tagging(port[:vlan_tagging])
    @current_resource.active = port[:_active]
    @current_resource.exists = true
  else
    @current_resource.active = false
    @current_resource.exists = false
  end
  @current_resource
end

def whyrun_supported?
  true
end

private

def junos_client
  @junos_client ||= Netdev::JunosApiClient::L2ports.new(new_resource.name)
end
