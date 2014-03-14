#
# Cookbook Name:: netdev
# Provider:: interface_junos
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

include Netdev::Provider::Common::Junos
use_inline_resources

action :create do
  new_values = new_resource.state
  current_values = current_resource.state

  new_values[:admin] = new_values.delete(:enable) ? :up : :down
  current_values[:admin] = current_values.delete(:enable) ? :up : :down

  updated_values = junos_client.updated_changed_properties(new_values,
                                                           current_values)
  unless updated_values.empty?
    message  = "create interface #{new_resource.name} with values:"
    message << " #{pretty_print_updated_values(updated_values)}"
    converge_by(message) do
      junos_client.write!
    end
  end
end

action :delete do
  if current_resource.exists?
    converge_by("delete existing interface #{new_resource.name}") do
      junos_client.delete!
    end
  end
end

def load_current_resource
  Chef::Log.info "Loading current resource #{new_resource.name}"

  @current_resource = Chef::Resource::NetdevInterface.new(new_resource.name)
  @current_resource.interface_name(new_resource.interface_name)
  # We want to override the default description generated for this
  # resource. Hacky workaround for the fact Chef::Resource#set_or_return
  # won't let us nil out an attribute.
  @current_resource.instance_variable_set('@description', nil)

  if (port = junos_client.managed_resource) && port.exists?

    if port[:admin] == :up
      @current_resource.enable(true)
    elsif port[:admin] == :down
      @current_resource.enable(false)
    end

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

def whyrun_supported?
  true
end

private

def junos_client
  @junos_client ||= Netdev::Junos::ApiClient::L1ports.new(new_resource.interface_name)
end
