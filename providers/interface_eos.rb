#
# Cookbook Name:: netdev
# Provider:: interface_eos
#
# Copyright 2013 Arista Networks
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

action :create do
  converge_by("create interface #{new_resource.name}") do
    params = Array.new()
    (params << "--admin" << new_resource.admin) if has_changed?(current_resource.admin, new_resource.admin)
    (params << "--description" << new_resource.description) if has_changed?(current_resource.description, new_resource.description)
    (params << "--mtu" << new_resource.mtu) if has_changed?(current_resource.mtu, new_resource.mtu)
    (params << "--speed" << new_resource.speed) if has_changed?(current_resource.speed, new_resource.speed)
    (params << "--duplex" << new_resource.duplex) if has_changed?(current_resource.duplex, new_resource.duplex)

    execute "netdev interface edit" do
      command "netdev interface edit #{new_resource.name} #{params.join(' ')}"
      not_if { params.empty? }
    end
  end
end

action :delete do
  converge_by("remove interface #{new_resource.name}") do
    execute "netdev interface delete" do
      command "netdev interface delete #{new_resource.name}"
    end
  end
end

def load_current_resource
  Chef::Log.info "Loading current resource #{@new_resource.name}"

  resp = eval run_command("netdev interface list --output ruby-hash")
  interface = resp['result'][@new_resource.name]

  @current_resource = Chef::Resource::NetdevInterface.new(@new_resource.name)
  @current_resource.admin(interface['admin'])
  @current_resource.description(interface['description'])
  @current_resource.mtu(interface['mtu'])
  @current_resource.speed(interface['speed'])
  @current_resource.duplex(interface['duplex'])
  @current_resource.exists = true

end

def has_changed?(curres, newres)
  return curres != newres && !newres.nil?
end


def run_command(command)
  Chef::Log.info "Running command: #{command}"
  command = Mixlib::ShellOut.new(command)
  command.run_command()
  return command.stdout
end

