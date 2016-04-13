require 'serverspec'
require 'pathname'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe command('cli show config groups service_group') do
  it { should return_stdout(/system/) }
end

describe command('cli show config apply-groups') do
  it { should_not return_stdout(/\s.*apply-groups \s.* service_group\s.*/) }
end
