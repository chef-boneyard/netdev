#
# Cookbook Name:: netdev
# Resource:: lag_eos
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
  converge_by("create lag #{@new_resource.name}") do
    if !@current_resource.exists
      converge_by("lag #{@new_resource.name} will be created") do
        create_lag
      end
    else
      converge_by("edit lag #{@new_resource.name} will be modified") do
        edit_lag
      end
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("remove lag #{@current_resource.name}") do
      execute 'netdev lag delete' do
        command "netdev lag delete #{new_resource.lag_name}"
      end
    end
  else
    Chef::Log.info("Lag #{new_resource.name} doesn't exist, nothing to delete")
  end
end

def load_current_resource
  Chef::Log.info "Loading current resource #{@new_resource.name}"
  @current_resource = Chef::Resource::NetdevLag.new(@new_resource.name)
  @current_resource.exists = false

  if resource_exists?
    resp = run_command('netdev lag list --output ruby-hash')
    lag = resp['result'][@new_resource.lag_name]
    @current_resource.links(lag['links'])
    @current_resource.minimum_links(lag['minimum_links'])
    @current_resource.lacp(lag['lacp'])
    @current_resource.exists = true

  else
    Chef::Log.info "Lag interface #{@new_resource.name} doesn't exist"
  end

end

def resource_exists?
  Chef::Log.info("Looking to see if lag #{@new_resource.name} exists")
  lags = run_command('netdev lag list --output ruby-hash')
  lags.key?(@new_resource.lag_name)
end

def has_changed?(curres, newres)
  curres != newres && !newres.nil?
end

def create_lag
  params = []
  (params << '--links' << new_resource.links.join(',')) if new_resource.links
  (params << '--minimum_links' << new_resource.minimum_links) if new_resource.minimum_links
  (params << '--lacp' << new_resource.lacp) if new_resource.lacp

  execute 'netdev lag create' do
    command "netdev lag create #{new_resource.lag_name} #{params.join(' ')}"
    not_if { params.empty? }
  end
end

def edit_lag
  params = []
  (params << '--links' << new_resource.links.join(',')) if has_changed?(current_resource.links, new_resource.links)
  (params << '--minimum_links' << new_resource.minimum_links) if has_changed?(current_resource.minimum_links, new_resource.minimum_links)
  (params << '--lacp' << new_resource.lacp) if has_changed(current_resource.lacp, new_resource.lacp)

  execute 'netdev lag edit' do
    command "netdev lag edit #{new_resource.lag_name} #{params.join(' ')}"
    not_if { params.empty? }
  end
end

def run_command(command)
  Chef::Log.info "Running command: #{command}"
  command = Mixlib::ShellOut.new(command)
  command.run_command
  command.stdout
end
