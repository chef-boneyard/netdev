#
# Cookbook Name:: netdev
# Provider:: interface_junos
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

  message  = "create interface #{new_resource.name} with values:"
  message << " #{updated_values.map{|e| e.join(" => ")}.join(", ")}"

  converge_by(message) do
    junos_client.commit!
    Chef::Log.debug("#{new_resource} wrote and committed configuration changes")
  end

  # Chef::Log.info("#{new_resource} created")
end

action :delete do
  if current_resource.exists
    converge_by("remove interface #{new_resource.name}") do
      junos_client.delete!
      Chef::Log.info("#{new_resource} deleted")
    end
  else
    Chef::Log.debug("#{new_resource} does not exist - nothing to do")

action :enable do
  if current_resource.exists? && !current_resource.active?
    converge_by("enable interface #{new_resource.name}") do
      junos_client.activate!
    end
  end
end

action :disable do
  if current_resource.exists? && current_resource.active?
    converge_by("disable interface #{new_resource.name}") do
      junos_client.deactivate!
    end
  end
end

def load_current_resource
  Chef::Log.info "Loading current resource #{new_resource.name}"

  @current_resource = Chef::Resource::NetdevInterface.new(new_resource.name)

  if (port = junos_client.managed_resource) && port.exists?
    @current_resource.admin(port[:admin].to_s)
    @current_resource.description(port[:description])
    @current_resource.mtu(port[:mtu])
    @current_resource.speed(port[:speed].to_s)
    @current_resource.duplex(port[:duplex].to_s)
    @current_resource.active = port[:_active]
    @current_resource.exists = true
  else
    @current_resource.active = false
    @current_resource.exists = false
  end
  @current_resource
end

private

def junos_client
  @junos_client ||= Netdev::JunosApiClient::L1ports.new(new_resource.name)
end
