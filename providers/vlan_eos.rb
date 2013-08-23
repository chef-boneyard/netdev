#
# Cookbook Name:: netdev
# Resource:: vlan_eos
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
  converge_by("create vlan #{@new_resource.name}") do
    if !@current_resource.exists
      converge_by("Vlan #{@new_resource.name} will be created") do
        create_vlan
      end
    else
      converge_by("edit vlan #{@new_resource.name} will be modified") do
        edit_vlan
      end
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("remove vlan #{@current_resource.name}") do
      execute "netdev vlan delete" do
        command "netdev vlan delete #{new_resource.vlan_id}"
      end
    end
  else
    Chef::Log.info("Vlan doesn't exist, nothing to delete")
  end
end

def load_current_resource
  Chef::Log.info "Loading current resource #{@new_resource.name}"
  @current_resource = Chef::Resource::NetdevVlan.new(@new_resource.name)
  @current_resource.vlan_id(@new_resource.vlan_id)
  @current_resource.exists = false

  if resource_exists?
    resp = eval run_command("netdev vlan list --output ruby-hash")
    vlan = resp['result'][@current_resource.vlan_id]
    @current_resource.vlan_id(vlan['vlan_id'])
    @current_resource.exists = true

  else
    Chef::Log.info "Vlan #{@new_resource.name} (#{@new_resource.vlan_id}) doesn't exist"
  end

end

def resource_exists?
  Chef::Log.info("Looking to see if vlan #{@new_resource.name} (#{@new_resource.vlan_id}) exists")
  vlans = eval run_command("netdev vlan list --output ruby-hash")
  return vlans.has_key?(@new_resource.vlan_id)
end

def create_vlan
  execute "netdev vlan create" do
    params = []
    params << "--name" << new_resource.name
    command "netdev vlan create #{new_resource.vlan_id} #{params.join(' ')}"
  end
end

def edit_vlan
  execute "netdev vlan edit" do
    params = []
    (params << "--name" << new_resource.name) if new_resource.name != current_resource.name
    command "netdev vlan edit #{new_resource.vlan_id} #{params.join(' ')}"
  end
end

def run_command(command)
  Chef::Log.info "Running command: #{command}"
  command = Mixlib::ShellOut.new(command)
  command.run_command()
  return command.stdout
end

