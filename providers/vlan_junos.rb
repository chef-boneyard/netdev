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

  message  = "create vlan #{new_resource.name} with values:"
  message << " #{updated_values.map{|e| e.join(" => ")}.join(", ")}"

  converge_by(message) do
    junos_client.write!
    Chef::Log.debug("#{new_resource} wrote and committed configuration changes")
  end
end

action :delete do
  if current_resource.exists
    converge_by("remove vlan #{new_resource.name}") do
      junos_client.delete!
      Chef::Log.info("#{new_resource} deleted")
    end
  else
    Chef::Log.debug("#{new_resource} does not exist - nothing to do")
  end
end

def load_current_resource
  Chef::Log.info "Loading current resource #{new_resource.name}"

  @current_resource = Chef::Resource::NetdevVlan.new(new_resource.name)

  if vlan = node['netdev']['vlan'][new_resource.name]
    @current_resource.vlan_id(vlan['vlan_id'])
    @current_resource.description(vlan['description'])
    @current_resource.exists = true
  else
    # Validation forces us to set something here
    @current_resource.vlan_id(-1)
    @current_resource.exists = false
  end

end

private

def junos_client
  @junos_client ||= Netdev::JunosApiClient::Vlans.new(new_resource.name)
end
