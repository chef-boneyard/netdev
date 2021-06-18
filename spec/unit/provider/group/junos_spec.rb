#
# Copyright:: 2014, Chef Software, Inc.
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

require 'spec_helper'

describe Chef::Provider::NetdevGroup::Junos do
  include_context 'provider_junos'

  let(:managed_resource) do
    grp = double('service_group', exists?: true)
    allow(grp).to receive(:[]).with(:template_path) { 'services.set.erb' }
    allow(grp).to receive(:[]).with(:_active) { true }
    grp
  end

  let(:new_resource) do
    new_resource = Chef::Resource::NetdevGroup.new('service_group')
    new_resource.template_path('services.set.erb')
    new_resource.variables(services: node['netdev']['services'])
    new_resource
  end

  describe '#action_create' do
    it 'creates the group if properties have changed' do
      junos_client.should_receive(:updated_changed_properties).and_return({})
      junos_client.should_receive(:write!).with(no_args)
      provider.run_action(:create)
    end

    it 'does nothing if properties are unchanged' do
      junos_client.should_receive(:updated_changed_properties).and_return({})
      provider.run_action(:create)
    end
  end

  describe '#action_delete' do
    it 'deletes the group' do
      junos_client.should_receive(:delete!).with(no_args)
      provider.run_action(:delete)
    end
  end
end
