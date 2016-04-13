Netdev Cookbook Changelog
=========================
This file is used to list changes made in each version of the netdev cookbook.

v2.0.0 (2014-03-19)
-------------------
Features:
 - Full provider coverage for Juniper switches running on the Junos platform.
 - `JunosCommitTransactionHandler` - Chef handler used to commit pending Junos
    candidate configuration changes at the end of a Chef run.
 - Full Test Kitchen support including Serverspec integration test coverage.

Improvements:
  - Converted all LWRPs to HWRPs
  - Rubocop style checking

v2.1.0 (2016-03-11)
-------------------
Features:
- Add netdev_group provider for Juniper devices.
- Add support for Juniper devices running BSD10 based JUNOS images.
- Add support for MX series Juniper device.

Bug fix:
  - Issue 7 ArgumentError: wrong number of arguments(2 for 0) error is coming while running chef for 
            occam device.
  - Issue 9 Chef client run throws error on JUNOS device when it is triggered second time.
  - Issue 10 Chef client run fails with "Netconf IO timed out while waiting for more data" error on 
             JUNOS MX device.
  - Issue 11 For netdev_group resource action :delete is not working as expected on a specific scenario 
             while invoking the template based chef recipe.
  - Issue 12 Chef client run fails while configuring interface with speed 10m on MX device.
  - Issue 13 Configuration database is not open Error is thrown if same recipe is invoked 
             again via Chef JUNOS Client.
  - Issue 14 TypeError: can't convert nil into String is thrown if the JUNOS configuration 
             format mentioned in the template file is invalid.
  - Issue 15 Chef is not throwing the proper warning message while deleting a netdev_group which 
             is protected.
  - Issue 18 If apply-group configuration it deleted, it is not configured during second Chef client run.

