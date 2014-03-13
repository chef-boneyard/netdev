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

shared_context 'provider_junos' do

  let(:junos_client) { double('junos_client', :managed_resource => managed_resource) }

  before do
    Netdev::Junos::ApiClient.stub(:new).and_return(junos_client)
  end

  let(:chef_run) do
    ChefSpec::Runner.new(:step_into => [resource_subject])
  end

  # Helpers
  def pending_lwrp_testability
    pending('Waiting for ChefSpec to add better testibility to LWRPs')
  end
end
