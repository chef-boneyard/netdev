netdev Cookbook
===============
[![Build Status](https://secure.travis-ci.org/opscode-cookbooks/omnibus.png?branch=master)](http://travis-ci.org/opscode-cookbooks/netdev)

Provides a set of vendor-agnostic resources for managing networking devices.

Requirements
------------

- Chef 11.0.0+
- Supported networking device from Arista or Juniper.

Usage
-----
Add a dependency on netdev to your cookbook's `metadata.rb`

```ruby
depends 'netdev'
```

Resources/Providers
-------------------

All resources are fully documented on [Chef's offical documentation site](http://docs.opscode.com/junos.html).

Resource | Description | Example Usage |
-------|-------------|---------|
__netdev_interface__ | This resource provides an abstraction for managing physical interfaces on network elements. | [netdev_interface integation test fixture](test/fixtures/cookbooks/interface/recipes/create.rb)
__netdev\_l2\_interface__ | This resource provides an abstraction for creating and deleting layer 2 interfaces on network devices. | [netdev_l2_interface integation test fixture](test/fixtures/cookbooks/l2_interface/recipes/create.rb).
__netdev\_lag__ | This resource provides an abstraction for creating and deleting link aggregation group interfaces. | [netdev_lag integation test fixture](test/fixtures/cookbooks/lag/recipes/create.rb).
__netdev\_vlan__ | This resource provides an abstraction for creating and deleting VLANs. | [netdev_vlan integation test fixture](test/fixtures/cookbooks/vlan/recipes/create.rb).

Testing
-------
You can run the tests in this cookbook using Rake:

```text
rake integration  # Run Test Kitchen integration tests
rake style        # Run all style checks
rake style:chef   # Lint Chef cookbooks
rake style:ruby   # Run Ruby style checks
rake travis:ci    # Run tests on Travis
```

Test Kitchen
------------

Test Kitchen 1.0.0+ ships with a [proxy driver](https://github.com/opscode/test-kitchen/commit/dc6af31bcfbc2decbfda4d905a185affe0ff101a) that proxies commands through to a test instance whose lifecycle is not managed by Test Kitchen. This driver is useful for testing against long-lived non-ephemeral test instances that are simply "reset" between test runs. This driver is also perfect for testing against physical network equipment!

You will need to specify the location and login details for the switch you will be running Test Kitchen against. This should be done in a `.kitchen.local.yml` file:

```yaml
platforms:
- name: junos-13.2
  driver:
    # Set the login user of the test switch
    username: schisamo
    # Set the ipaddress or DNS name of the test switch.
    host: 10.66.44.10
    # Set the port sshd is listening on; defaults to 22.
    port: 22
```

This repository ships with an example file which can easily be copied into place:

```
cp kitchen.local.example.yml kitchen.local.yml
```

### Juniper Equipment

Requirements:

* Juniper switch/router running `JUNOS 13.2*` (other Junos versions
may work).
* Switch is [configured for external remote access via SSH](http://www.juniper.net/techpubs/en_US/junos/topics/task/configuration/ssh-services-configuring.html).
* A valid user account on the test switch [configured for passwordless key-based SSH access](http://pileofbits.com/2013/03/11/junos-ssh-key-authentication/).

Test run resets on Juniper device is achieved using Juno's [rescue configuration](http://www.juniper.net/techpubs/en_US/junos11.4/topics/task/configuration/junos-software-rescue-configuration-creating-restoring.html) feature. A _rescue configuration_ allows you to define a known working configuration or a configuration with a known state that you can roll back to at any time.

Creating a rescue configuration is easy. SSH into your switch and run the following command:

```
{master:0}
schisamo@junos-chef-dev> request system configuration rescue save

{master:0}
schisamo@junos-chef-dev>
```

You now have a known good state to roll back to! Test Kitchen activates the rescue
configuration by issuing the command `cli -c 'configure; rollback rescue; commit'`
during the CREATE and DESTROY stages of testing. Reference the [.kitchen.yml](.kitchen.yml)
for some additional environment variables that are used to set `host`, `username` and
sshd `port` of the switch being tested against.

### Arista Equipment

Currently not supported.

License & Authors
-----------------

- Author: Peter Sprygada (Arista Networks)
- Author: Jeremy Schulman (Juniper Networks)
- Author: Seth Chisamore (CHEF, Inc.)

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
