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

shared_context 'provider_junos' do
  let(:junos_client) do
    double('junos_client', managed_resource: managed_resource)
  end

  let(:run_context) do
    node        = Chef::Node.new
    events      = Chef::EventDispatch::Dispatcher.new
    run_context = Chef::RunContext.new(node, {}, events)
    run_context
  end

  let(:provider) do
    described_class.new(new_resource, run_context)
  end

  before do
    Netdev::Junos::ApiClient.stub(:new).and_return(junos_client)
  end
end
