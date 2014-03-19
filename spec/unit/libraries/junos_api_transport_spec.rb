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

describe Netdev::Junos::ApiTransport do
  let(:transport) { double('transport') }
  let(:transport_config) { double('transport_config') }

  subject do
    described_class.any_instance.stub(:open_connection!)
    described_class.instance.instance_variable_set('@transport', transport)
    described_class.instance.instance_variable_set('@transport_config', transport_config)
    described_class.instance
  end

  it 'behaves like a singleton' do
    expect { described_class.new }.to raise_error(NoMethodError)
  end

  describe 'delegated methods' do
    it { should respond_to(:[]) }
    it { should respond_to(:l1_ports) }
    it { should respond_to(:l2_ports) }
    it { should respond_to(:ip_ports) }
    it { should respond_to(:vlans) }
    it { should respond_to(:lag_ports) }
    it { should respond_to(:unlock!) }
    it { should respond_to(:unlock!) }
    it { should respond_to(:commit?) }
    it { should respond_to(:commit!) }
    it { should respond_to(:rollback!) }
  end

  describe 'transaction handling' do
    it 'acquires an exclusive lock when starting a transaction' do
      expect(transport_config).to receive(:lock!).once
      subject.start_transaction!
      expect(subject.transaction_open?).to be_true
    end

    it 'releases the exclusive lock when committing transaction' do
      expect(transport_config).to receive(:commit!).once
      expect(transport_config).to receive(:unlock!).once
      subject.commit_transaction!
      expect(subject.transaction_open?).to be_false
    end
  end

end
