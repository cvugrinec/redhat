require 'spec_helper'
describe 'nexus_rws' do

  context 'with defaults for all parameters' do
    it { should contain_class('nexus_rws') }
  end
end
