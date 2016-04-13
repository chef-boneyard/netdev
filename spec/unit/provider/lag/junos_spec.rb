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

require 'spec_helper'

describe Chef::Provider::NetdevLinkAggregationGroup::Junos do
  include_context 'provider_junos'

  let(:managed_resource) do
    lag = double('lag', exists?: true)
    allow(lag).to receive(:[]).with(:links) { %w( ge-0/0/1 ge-0/0/2 ) }
    allow(lag).to receive(:[]).with(:minimum_links) { 2 }
    allow(lag).to receive(:[]).with(:lacp) { 'disabled' }
    allow(lag).to receive(:[]).with(:_active) { true }
    lag
  end

  let(:new_resource) do
    new_resource = Chef::Resource::NetdevLinkAggregationGroup.new('ae0')
    new_resource.links(%w( ge-0/0/1 ge-0/0/2 ))
    new_resource.minimum_links(1)
    new_resource.lacp('disable')
    new_resource
  end

  let(:provider) do
    described_class.new(new_resource, run_context)
  end

  describe '#load_current_resource' do
    describe 'wires managed_resource names to attribute names' do
      it 'translate disabled to disable' do
        pending
      end
    end
  end

  describe '#action_create' do
    it 'creates the link aggregation group if properties have changed' do
      junos_client.should_receive(:updated_changed_properties).and_return(minimum_links: 1)
      junos_client.should_receive(:write!).with(no_args)
      provider.run_action(:create)
    end

    it 'does nothing if properties are unchanged' do
      junos_client.should_receive(:updated_changed_properties).and_return({})
      provider.run_action(:create)
    end
  end

  describe '#action_delete' do
    it 'deletes the link aggregation group' do
      junos_client.should_receive(:delete!).with(no_args)
      provider.run_action(:delete)
    end
  end
end
