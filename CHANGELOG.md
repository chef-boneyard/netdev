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
