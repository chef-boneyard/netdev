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

describe Chef::Provider::NetdevInterface::Junos do
  include_context 'provider_junos'

  let(:managed_resource) do
    port = double('port', exists?: true)
    allow(port).to receive(:[]).with(:admin) { :up }
    allow(port).to receive(:[]).with(:description) { 'blahblahblah' }
    allow(port).to receive(:[]).with(:mtu) { 3 }
    allow(port).to receive(:[]).with(:speed) { '1g' }
    allow(port).to receive(:[]).with(:duplex) { :auto }
    allow(port).to receive(:[]).with(:_active) { true }
    port
  end

  let(:new_resource) do
    new_resource = Chef::Resource::NetdevInterface.new('ge-0/0/0')
    new_resource.description('All your interfaces are belong to Chef')
    new_resource.speed('1g')
    new_resource.duplex('full')
    new_resource
  end

  let(:provider) do
    described_class.new(new_resource, run_context)
  end

  describe '#load_current_resource' do
    describe 'wires managed_resource names to attribute names' do
      it 'translates :up to true' do
        pending
      end

      it 'translates :down to false' do
        pending
      end

      it 'translates any other value to nil' do
        pending
      end
    end
  end

  describe '#action_create' do
    it 'creates the interface if properties have changed' do
      junos_client.should_receive(:updated_changed_properties).once.and_return(description: 'poopy')
      junos_client.should_receive(:write!).once.with(no_args)
      provider.run_action(:create)
    end

    it 'does nothing if properties are unchanged' do
      junos_client.should_receive(:updated_changed_properties).once.and_return({})
      provider.run_action(:create)
    end
  end

  describe '#action_delete' do
    it 'deletes the interface' do
      junos_client.should_receive(:delete!).with(no_args)
      provider.run_action(:delete)
    end
  end
end
