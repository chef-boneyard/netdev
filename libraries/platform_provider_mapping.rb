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

require 'chef/platform'

require_relative 'provider_interface_eos'
require_relative 'provider_interface_junos'
require_relative 'provider_l2_interface_eos'
require_relative 'provider_l2_interface_junos'
require_relative 'provider_lag_eos'
require_relative 'provider_lag_junos'
require_relative 'provider_vlan_eos'
require_relative 'provider_vlan_junos'
require_relative 'provider_group_junos'

#########################################################################
# Chef::Resource::NetdevInterface Providers
#########################################################################
Chef::Platform.set(
  platform: :eos,
  resource: :netdev_interface,
  provider: Chef::Provider::NetdevInterface::EOS
)

Chef::Platform.set(
  platform: :junos,
  resource: :netdev_interface,
  provider: Chef::Provider::NetdevInterface::Junos
)

Chef::Platform.set(
  version:  "JNPR",
  resource: :netdev_interface,
  provider: Chef::Provider::NetdevInterface::Junos
)

#########################################################################
# Chef::Resource::NetdevL2Interface Providers
#########################################################################
Chef::Platform.set(
  platform: :eos,
  resource: :netdev_l2_interface,
  provider: Chef::Provider::NetdevL2Interface::EOS
)

Chef::Platform.set(
  platform: :junos,
  resource: :netdev_l2_interface,
  provider: Chef::Provider::NetdevL2Interface::Junos
)

Chef::Platform.set(
  version: "JNPR",
  resource: :netdev_l2_interface,
  provider: Chef::Provider::NetdevL2Interface::Junos
)

#########################################################################
# Chef::Resource::NetdevLinkAggregationGroup Providers
#########################################################################
Chef::Platform.set(
  platform: :eos,
  resource: :netdev_lag,
  provider: Chef::Provider::NetdevLinkAggregationGroup::EOS
)

Chef::Platform.set(
  platform: :junos,
  resource: :netdev_lag,
  provider: Chef::Provider::NetdevLinkAggregationGroup::Junos
)

Chef::Platform.set(
  version: "JNPR",
  resource: :netdev_lag,
  provider: Chef::Provider::NetdevLinkAggregationGroup::Junos
)

#########################################################################
# Chef::Resource::NetdevVirtualLAN Providers
#########################################################################
Chef::Platform.set(
  platform: :eos,
  resource: :netdev_vlan,
  provider: Chef::Provider::NetdevVirtualLAN::EOS
)

Chef::Platform.set(
  platform: :junos,
  resource: :netdev_vlan,
  provider: Chef::Provider::NetdevVirtualLAN::Junos
)

Chef::Platform.set(
  version: "JNPR",
  resource: :netdev_vlan,
  provider: Chef::Provider::NetdevVirtualLAN::Junos
)

#########################################################################
# Chef::Resource::NetdevGroup Providers
#########################################################################
Chef::Platform.set(
  platform: :junos,
  resource: :netdev_group,
  provider: Chef::Provider::NetdevGroup::Junos
)

Chef::Platform.set(
  version: "JNPR",
  resource: :netdev_group,
  provider: Chef::Provider::NetdevGroup::Junos
)
