#
# Author:: Seth Chisamore <schisamo@opscode.com>
#
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
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

describe 'netdev_vlan_junos provider' do
  include_context 'provider_junos'

  let(:resource_subject) { 'netdev_vlan' }

  let(:managed_resource) do
    vlan = double('vlan', :exists? => true)
    allow(vlan).to receive(:[]).with(:vlan_id) { 2 }
    allow(vlan).to receive(:[]).with(:description) { 'blahblahblah' }
    allow(vlan).to receive(:[]).with(:_active) { true }
    vlan
  end

  describe '#action_create' do
    it 'creates the vlan if properties have changed' do
      junos_client.should_receive(:updated_changed_properties).and_return({ :description => 'poopy' })
      junos_client.should_receive(:write!).with(no_args)
      chef_run.converge('netdev-test::vlan_create')
    end

    it 'does nothing if properties are unchanged' do
      junos_client.should_receive(:updated_changed_properties).and_return({})
      chef_run.converge('netdev-test::vlan_create')
    end
  end

  describe '#action_delete' do
    it 'deletes the vlan' do
      junos_client.should_receive(:delete!).with(no_args)
      chef_run.converge('netdev-test::vlan_delete')
    end
  end
end