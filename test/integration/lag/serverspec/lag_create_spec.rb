require 'serverspec'
require 'pathname'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

%w[ge-0/0/1 ge-0/0/2].each do |l2_interface|
  describe command("cli show config interfaces #{l2_interface}") do
    it { should return_stdout(/802.3ad ae0;/) }
  end
end

describe command('cli show configuration interfaces ae0') do
  it { should return_stdout(/minimum-links 1;/) }
end
