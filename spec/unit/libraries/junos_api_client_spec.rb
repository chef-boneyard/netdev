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

describe Netdev::Junos::ApiClient do
  describe 'metaprogrammed child classes' do
    subject { described_class }

    it { should have_constant(:L1ports) }
    it { should have_constant(:L2ports) }
    it { should have_constant(:IPports) }
    it { should have_constant(:Vlans) }
    it { should have_constant(:LAGports) }
  end

  describe 'child instances' do
    let(:resource_name) { 'ge-0/0/0' }
    let(:transport) do
      double('transport',
             :transaction_open? => true,
             :start_transaction! => true,
             :l1_ports => { resource_name => managed_resource },
             :commit? => true)
    end
    let(:managed_resource) do
      double('managed_resource',
             :write! => true,
             :delete! => true,
             :activate! => true,
             :deactivate! => true,
             :should => {},
             :properties => Junos::Ez::L1ports::PROPERTIES)
    end

    subject do
      instance = described_class.const_get(:L1ports).new(resource_name)
      instance.stub(:transport).and_return(transport)
      instance
    end

    [:write!, :delete!, :activate!, :deactivate!].each do |action|
      it "performs a config check after action: #{action}" do
        expect(transport).to receive(:commit?).once
        subject.send(action)
      end
    end

    it 'raises an exception if the config check fails' do
      transport.should_receive(:commit?).and_raise(Netconf::RpcError.new('foo',
                                                                         'bar',
                                                                         'baz'))
      expect { subject.write! }.to raise_error
    end

    it 'starts a single transaction' do
      expect(transport).to receive(:transaction_open?).and_return(false, true)
      expect(transport).to receive(:start_transaction!).once
      subject.write!
      subject.delete!
    end

    describe '#updated_changed_properties' do
      let(:existing_values) { { :admin => true, :description => 'WAT' } }
      let(:new_values) { { :admin => false, :description => 'WAT' } }

      it 'updates only the properties that have changed' do
        expect(managed_resource).to receive(:[]=).once.with(:admin, false)
        subject.updated_changed_properties(new_values, existing_values)
      end

      described_class.const_get('VALUES_TO_SYMBOLIZE').each do |val|
        context "when passed a property set to a String of: #{val}" do
          let(:new_values) { { :duplex => val.to_s } }

          it 'converts the value to a Symbol' do
            expect(managed_resource).to receive(:[]=).once.with(:duplex, val.to_sym)
            subject.updated_changed_properties(new_values, existing_values)
          end
        end
      end

      context 'when passed an unknown property' do
        let(:new_values) { { :foo => 'bar' } }

        it 'raises an exception' do
          expect do
            subject.updated_changed_properties(new_values, existing_values)
          end.to raise_error(ArgumentError)
        end
      end

      context 'when passed a property set to nil' do
        let(:new_values) { { :description => nil } }

        it 'treats the value as unchanged' do
          expect(managed_resource).to receive(:[]=).never
        end
      end

    end
  end
end
