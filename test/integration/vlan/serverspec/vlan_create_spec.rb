require 'serverspec'
require 'pathname'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe command('cli show config vlans') do
  it { should return_stdout(/chef-test \{/) }
  it do
    should return_stdout(
      /description "Ain't no party like a vlan party! YO YO YO";/
    )
  end
end
