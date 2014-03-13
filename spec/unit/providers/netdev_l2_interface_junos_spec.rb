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

describe 'netdev_l2_interface_junos provider' do
  include_context 'provider_junos'

  let(:resource_subject) { 'netdev_l2_interface' }

  let(:managed_resource) do
    port = double('port', :exists? => true)
    allow(port).to receive(:[]).with(:description) { 'blahblahblah' }
    allow(port).to receive(:[]).with(:untagged_vlan) { 'default' }
    allow(port).to receive(:[]).with(:tagged_vlans) { %w{ chef-test } }
    allow(port).to receive(:[]).with(:vlan_tagging) { true }
    allow(port).to receive(:[]).with(:_active) { true }
    port
  end

  describe '#action_create' do
    it 'creates the layer 2 interface if properties have changed' do
      junos_client.should_receive(:updated_changed_properties).and_return({ :description => 'poopy' })
      junos_client.should_receive(:write!).with(no_args)
      chef_run.converge('l2_interface::create')
    end

    it 'does nothing if properties are unchanged' do
      junos_client.should_receive(:updated_changed_properties).and_return({})
      chef_run.converge('l2_interface::create')
    end
  end

  describe '#action_delete' do
    it 'deletes the layer 2 interface' do
      junos_client.should_receive(:delete!).with(no_args)
      chef_run.converge('l2_interface::delete')
    end
  end
end
