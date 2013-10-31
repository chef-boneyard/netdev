require 'spec_helper'

describe command('cli show config vlans') do
  it { should return_stdout(/chef-test/) }
end
