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

describe command('cli show config interfaces ge-0/0/0') do
  it { should return_stdout(/interface-mode trunk;/) }
  it { should return_stdout(/vlan \{\s.*members chef-test;/) }
  it do
    should return_stdout(
      %r{description "Chef created layer 2 interface: ge-0/0/0";}
    )
  end
end
