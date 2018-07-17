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

# Deactivate the layer 2 interfaces. We need to remove these interfaces
# from logical unit 0 before they can be aggregated links
netdev_l2_interface 'ge-0/0/1' do
  action :delete
end

netdev_l2_interface 'ge-0/0/2' do
  action :delete
end

netdev_lag 'ae0' do
  links %w[ge-0/0/1 ge-0/0/2]
  minimum_links 1
  lacp 'disable'
  action :create
end
