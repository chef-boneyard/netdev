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

require 'berkshelf'
require 'chefspec'

# load all shared examples and shared contexts
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each do |file|
  require(file)
end

# Stop 'already initialized constant' warnings. These
# warnings appear because we load the library files
# twice: once in this file and once by the Chef run.
$VERBOSE = nil

# load all library files for easy mocking
libs = File.expand_path('../../libraries', __FILE__)
$LOAD_PATH.unshift(libs) unless $LOAD_PATH.include?(libs)
Dir[File.join(libs, '*.rb')].each do |lib|
  require File.basename(lib, '.rb')
end

Berkshelf.ui.mute do
  berksfile = Berkshelf::Berksfile.from_file('Berksfile')
  berksfile.install(:path => 'vendor/cookbooks')
end

RSpec.configure do |config|
  # Use color in STDOUT
  config.color_enabled = true

  # specify metadata with symobls only (ie no '=> true' required)
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

RSpec::Matchers.define :have_constant do |const|
  match do |owner|
    owner.const_defined?(const)
  end
end
