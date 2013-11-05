require 'serverspec'
require 'pathname'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe command('cli show config interfaces ge-0/0/0') do
  it { should return_stdout(/speed \{\s.*1g;/) }
  it { should return_stdout(/link-mode full-duplex;/) }
  it { should return_stdout(/description "All your interfaces are belong to Chef";/) }
end
