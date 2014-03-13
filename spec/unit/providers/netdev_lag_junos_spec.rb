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

describe 'netdev_lag_junos provider' do
  include_context 'provider_junos'

  let(:resource_subject) { 'netdev_lag' }

  let(:managed_resource) do
    lag = double('lag', :exists? => true)
    allow(lag).to receive(:[]).with(:links) { %w{ ge-0/0/1 ge-0/0/2 } }
    allow(lag).to receive(:[]).with(:minimum_links) { 2 }
    allow(lag).to receive(:[]).with(:lacp) { 'disabled' }
    allow(lag).to receive(:[]).with(:_active) { true }
    lag
  end

  describe '#load_current_resource' do

    describe 'wires managed_resource names to attribute names' do
      it 'translate disabled to disable' do
        pending_lwrp_testability
      end
    end
  end

  describe '#action_create' do
    it 'creates the link aggregation group if properties have changed' do
      junos_client.should_receive(:updated_changed_properties).and_return({ :minimum_links => 1 })
      junos_client.should_receive(:write!).with(no_args)
      chef_run.converge('lag::create')
    end

    it 'does nothing if properties are unchanged' do
      junos_client.should_receive(:updated_changed_properties).and_return({})
      chef_run.converge('lag::create')
    end
  end

  describe '#action_delete' do
    it 'deletes the link aggregation group' do
      junos_client.should_receive(:delete!).with(no_args)
      chef_run.converge('lag::delete')
    end
  end
end
