#
# Cookbook Name:: netdev
# Resource:: l2_interface_eos
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
  converge_by("create l2interface #{@new_resource.name}") do
    if !@current_resource.exists
      converge_by("L2interface #{@new_resource.name} will be created") do
        create_l2interface
      end
    else
      converge_by("edit l2interface #{@new_resource.name} will be modified") do
        edit_l2interface
      end
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("remove l2interface #{@current_resource.name}") do
      execute "netdev l2interface delete" do
        command "netdev l2interface delete #{new_resource.name}"
      end
    end
  else
    Chef::Log.info("L2interface doesn't exist, nothing to delete")
  end
end

def load_current_resource
  Chef::Log.info "Loading current resource #{@new_resource.name}"
  @current_resource = Chef::Resource::NetdevL2Interface.new(@new_resource.name)
  @current_resource.exists = false

  if resource_exists?
    resp = eval run_command("netdev l2interface list --output ruby-hash")
    interface = resp['result'][@new_resource.name]
    @current_resource.description(interface['description'])
    @current_resource.untagged_vlan(interface['untagged_vlan'])
    @current_resource.tagged_vlans(interface['tagged_vlans'])
    @current_resource.vlan_tagging(interface['vlan_tagging'])
    @current_resource.exists = true

  else
    Chef::Log.info "L2 interface #{@new_resource.name} doesn't exist"
  end

end

def resource_exists?
  Chef::Log.info("Looking to see if l2interface #{@new_resource.name} exists")
  interfaces = eval run_command("netdev l2interface list --output ruby-hash")
  return interfaces.has_key?(@new_resource.name)
end

def has_changed?(curres, newres)
  return curres != newres && !newres.nil?
end

def create_l2interface
  params = Array.new()
  (params << "--description" << new_resource.description) if new_resource.description
  (params << "--untagged_vlan" << new_resource.untagged_vlan) if new_resource.untagged_vlan
  (params << "--tagged_vlans" << new_resource.tagged_vlans.join(',')) if new_resource.tagged_vlans
  (params << "--vlan_tagging" << new_resource.vlan_tagging) if new_resource.vlan_tagging
  if !params.empty?
    execute "netdev l2interface create" do
      command "netdev l2interface create #{new_resource.name} #{params.join(' ')}"
    end
  end
end

def edit_l2interface
  params = Array.new()
  (params << "--description" << new_resource.description) if has_changed?(current_resource.description, new_resource.description)
  (params << "--untagged_vlan" << new_resource.untagged_vlan) if has_changed?(current_resource.untagged_vlan, new_resource.untagged_vlan)
  (params << "--tagged_vlans" << new_resource.tagged_vlans.join(',')) if has_changed?(current_resource.tagged_vlans, new_resource.tagged_vlans)
  (params << "--vlan_tagging" << new_resource.vlan_tagging) if has_changed?(current_resource.vlan_tagging, new_resource.vlan_tagging)
  if !params.empty?
    execute "netdev l2interface edit" do
      command "netdev l2interface edit #{new_resource.name} #{params.join(' ')}"
    end
  end
end

def run_command(command)
  Chef::Log.info "Running command: #{command}"
  command = Mixlib::ShellOut.new(command)
  command.run_command()
  return command.stdout
end

