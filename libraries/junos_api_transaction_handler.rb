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

begin
  require ' net/netconf/exception'
rescue LoadError
  msg  = "Could not load the junos-ez-stdlib gem..."
  msg << "ensure you are using the Chef for Junos packages"
  Chef::Log.debug msg
end

class JunosCommitTransactionHandler < Chef::Handler
  def report
    # Ensure handler is no-op in why-run mode and on non-Junos platforms.
    if (node['platform'] == 'junos') && !Chef::Config[:why_run]
      begin
        # on successful Chef-runs commit the transaction
        if success?
          Netdev::Junos::ApiTransport.instance.commit_transaction!
        # on failed Chef-runs rollback the transaction
        else
          Netdev::Junos::ApiTransport.instance.rollback!
          Chef::Log.info("Rolled back pending Junos candidate configuration changes")
        end
      rescue Netconf::RpcError => e
        Chef::Log.error("Could not complete Junos configuration transaction: #{e}")
      end
    end
  end
end

Chef::Config[:report_handlers].reject! {|i| i.kind_of?(JunosCommitTransactionHandler) }
Chef::Config[:report_handlers] << JunosCommitTransactionHandler.new

Chef::Config[:exception_handlers].reject! {|i| i.kind_of?(JunosCommitTransactionHandler) }
Chef::Config[:exception_handlers] << JunosCommitTransactionHandler.new
