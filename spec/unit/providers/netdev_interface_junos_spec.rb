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

describe 'netdev_interface_junos provider' do
  include_context 'provider_junos'

  let(:resource_subject) { 'netdev_interface' }

  let(:managed_resource) do
    port = double('port', :exists? => true)
    allow(port).to receive(:[]).with(:admin) { :up }
    allow(port).to receive(:[]).with(:description) { 'blahblahblah' }
    allow(port).to receive(:[]).with(:mtu) { 3 }
    allow(port).to receive(:[]).with(:speed) { '1g' }
    allow(port).to receive(:[]).with(:duplex) { :auto }
    allow(port).to receive(:[]).with(:_active) { true }
    port
  end

  describe '#load_current_resource' do

    describe 'wires managed_resource names to attribute names' do
      it 'translates :up to true' do
        pending_lwrp_testability
      end

      it 'translates :down to false' do
        pending_lwrp_testability
      end

      it 'translates any other value to nil' do
        pending_lwrp_testability
      end
    end
  end

  describe '#action_create' do
    it 'creates the interface if properties have changed' do
      junos_client.should_receive(:updated_changed_properties).twice.and_return({ :description => 'poopy' })
      junos_client.should_receive(:write!).twice.with(no_args)
      chef_run.converge('fake::interface_create')
    end

    it 'does nothing if properties are unchanged' do
      junos_client.should_receive(:updated_changed_properties).twice.and_return({})
      chef_run.converge('fake::interface_create')
    end
  end

  describe '#action_delete' do
    it 'deletes the interface' do
      junos_client.should_receive(:delete!).with(no_args)
      chef_run.converge('fake::interface_delete')
    end
  end
end
