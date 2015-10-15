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

require 'chef/handler'

require_relative '_junos_api_transport'

begin
  require ' net/netconf/exception'
rescue LoadError
  msg  = 'Could not load the junos-ez-stdlib gem...'
  msg << 'ensure you are using the Chef for Junos packages'
  Chef::Log.debug msg
end

# Chef handler used to commit pending Junos
# candidate configuration changes.
class JunosCommitTransactionHandler < Chef::Handler
  def report
    # Ensure handler is no-op in why-run mode and non-Junos platforms.
    if (node['platform'] == 'junos' || (node['platform_version'].include? "JNPR")) && !Chef::Config[:why_run]
      begin
        # on successful Chef-runs commit the transaction
        if success?
          commit_log_comment = nil

          # Attempt to extract a run id from the run context
          run_id = extract_run_id(run_context)

          if run_id
            commit_log_comment = "Chef Run ID: #{run_id}"
          else
            Chef::Log.debug('Could not extract a Chef run ID for the Junos commit log.')
          end

          Netdev::Junos::ApiTransport.instance.commit_transaction!(commit_log_comment)
        # on failed Chef-runs rollback the transaction
        else
          Netdev::Junos::ApiTransport.instance.rollback!
          Chef::Log.info('Rolled back pending Junos candidate configuration changes')
        end
      rescue Netconf::RpcError => e
        failure_msg = "Could not complete Junos configuration transaction: \n\n#{e}"
        Chef::Log.fatal(failure_msg)
        raise(failure_msg)
      end
    end
  end

  # We have to override this method so we can force a non-zero exit on
  # transaction commit failures.
  def run_report_safely(run_status)
    run_report_unsafe(run_status)
    @run_status = nil
  end

  private

  # Currently the a Chef run's unique UUID only lives in an instance of
  # `Chef::ResourceReporter` which is created for each Chef run. It
  # would be nice to push this run ID higher up into Chef so it is
  # easier to extract.
  #
  # Currently chef-solo does not register a `Chef::ResourceReporter`
  # handler so this method will return nil in that case.
  def extract_run_id(run_context)
    # Chef 11.8.2+ exposes a run_id to report handlers
    if self.respond_to?(:run_id)
      run_id
    # If we are running on older Chef we'll go trolling the event
    # handlers for a resource reporter (which generates a run ID).
    else
      resource_reporter = nil
      if run_context.events.instance_variable_defined?('@subscribers')
        subscribers = run_context.events.instance_variable_get('@subscribers')
        if subscribers
          resource_reporter = subscribers.find do |handler|
            handler.kind_of?(Chef::ResourceReporter)
          end
        end
      end
      resource_reporter.run_id if resource_reporter
    end
  end
end

Chef::Config[:report_handlers].reject! { |i| i.kind_of?(JunosCommitTransactionHandler) }
Chef::Config[:report_handlers] << JunosCommitTransactionHandler.new

Chef::Config[:exception_handlers].reject! { |i| i.kind_of?(JunosCommitTransactionHandler) }
Chef::Config[:exception_handlers] << JunosCommitTransactionHandler.new
