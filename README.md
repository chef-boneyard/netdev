netdev Cookbook
===============

Provides a set of vendor-agnostic resources for managing networking devices.

Requirements
------------

* Chef 11+
* Supported switch from Arista or Juniper.

TODO: add links to vendor specific requirements

Usage
-----

Add a dependency on netdev to your cookbook's `metadata.rb`

```ruby
depends 'netdev'
```

Resources/Providers
-------------------

### netdev_interface

This resource provides an abstraction for managing physical interfaces on network elements.

#### Actions
Action  | Description                     | Default
------- |-------------                    |---------
create  | Creates the physical interface. | Yes |
delete  | Deletes the physical interface. |     |

#### Attributes
Attribute      | Description | Type | Acceptable Values | Default |
---------      |------------ |----- |------------- |-------- |
interface_name | The interface name, for example, `ge-0/0/0` | String | | current resource name |
enable         | Configures the interface as administratively enabled or disabled | Boolean | `true`, `false` | `true` |
description    | Configures the interface description | String | | `Chef created interface: RESOURCE_NAME` |
mtu            | Configures the maximum transmission unit (MTU) of the interface. | Integer | | |
speed          | Configures the interface speed. | String | `auto`, `100m`, `1g`, `10g`, `40g`, `56g`, `100g` | `auto` |
duplex         | Configures the interface duplex mode | String | `auto`, `half`, `full` | `auto` |

#### Examples

Please see the [netdev_interface integation test fixture](test/fixtures/cookbooks/fake/recipes/interface_create.rb).

### netdev\_l2\_interface

This resource provides an abstraction for creating and deleting layer 2 interfaces on network devices.

#### Actions
Action  | Description                    | Default
------- |-------------                   |---------
create  | Creates the layer 2 interface. | Yes |
delete  | Deletes the layer 2 interface. |     |

#### Attributes
Attribute           | Description | Type | Acceptable Values | Default |
---------           |------------ |----- |------------- |-------- |
l2\_interface\_name | The layer 2 interface name, for example, `ge-0/0/0` | String | | current resource name |
description         | Configures the interface description | String | | `Chef created l2_interface: RESOURCE_NAME` |
untagged_vlan       | Configures the specified VLAN as the native VLAN on an interface. The value is the name of the VLAN for untagged packets. | String | | |
tagged_vlans        | Configures one or more VLANs that can carry traffic on a trunk interface. This value is an array of VLAN names. | Array |  |  |
vlan_tagging        | Configures the mode for the given port as access or trunk. A value of `true` configures the port in trunk mode, in which tagged packets are processed. A value of `false`, which is the default, configures the port in access mode, in which tagged packets are discarded. | Boolean | `true`, `false` | `false` |

#### Examples

Please see the [netdev_l2_interface integation test fixture](test/fixtures/cookbooks/fake/recipes/l2_interface_create.rb).

### netdev_lag

This resource provides an abstraction for creating and deleting link aggregation group interfaces.

#### Actions
Action  | Description                          | Default
------- |-------------                         |---------
create  | Creates the link aggregration group. | Yes |
delete  | Deletes the link aggregration group. |     |

#### Attributes
Attribute     | Description | Type | Acceptable Values | Default |
---------     |------------ |----- |------------- |-------- |
lag_name      | The LAG name excluding any logical unit number, for example, `ae0` | String | | current resource name |
links         | Configures one or more physical interfaces as members of the LAG bundle. The value is an array of interfaces names. | Array |  |  |
minimum_links | Integer that defines the minimum number of physical links that must be in the up state to declare the LAG port in the up state. | Integer | |  |
lacp          | Specifies the Link Aggregation Control Protocol (LACP) mode | String | `disabled` (LACP is not used) `active` (LACP active mode), `passive` (LACP passive mode) | disable |

#### Examples

Please see the [netdev_lag integation test fixture](test/fixtures/cookbooks/fake/recipes/lag_create.rb).

### netdev_vlan

This resource provides an abstraction for creating and deleting VLANs.

#### Actions
Action  | Description                     | Default
------- |-------------                    |---------
create  | Creates the physical interface. | Yes |
delete  | Deletes the physical interface. |     |

#### Attributes
Attribute   | Description | Type | Acceptable Values | Default |
---------   |------------ |----- |------------- |-------- |
vlan_name   | The name of the VLAN, which must be a VLAN name that is valid on the agent node. | String | | current resource name |
vlan_id     | Defines the VLAN ID. | Integer | 1-4094 |  |
description | Configures the VLAN description | String | | `Chef created vlan: RESOURCE_NAME` |

#### Examples

Please see the [netdev_vlan integation test fixture](test/fixtures/cookbooks/fake/recipes/vlan_create.rb).

Development
-----------
This section details "quick development" steps. For a detailed explanation, see [[Contributing.md]].

1. Clone this repository from GitHub:

        $ git clone git@github.com:opscode-cookbooks/netdev.git

2. Create a git branch

        $ git checkout -b my_bug_fix

3. Install dependencies:

        $ bundle install

4. Make your changes/patches/fixes, committing appropiately
5. **Write tests**
6. Run the tests:
    - `bundle exec foodcritic -f any .`
    - `bundle exec rspec`
    - `bundle exec rubocop`
    - `bundle exec kitchen test`

    In detail:
    - Foodcritic will catch any Chef-specific style errors
    - RSpec will run the unit tests
    - Rubocop will check for Ruby-specific style errors
    - Test Kitchen will run and converge the recipes

License and Authors
-------------------

|               |                                          |
|:--------------|:-----------------------------------------|
| **Author**    | Peter Sprygada (Arista Networks)         |
| **Author**    | Jeremy Schulman (Juniper Networks)       |
| **Author**    | Seth Chisamore (Opscode, Inc.)           |
|               |                                          |
| **Copyright** | Copyright (c) 2013 Arista Networks       |
| **Copyright** | Copyright (c) 2013 Juniper Networks      |
| **Copyright** | Copyright (c) 2013 Opscode, Inc.         |

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
