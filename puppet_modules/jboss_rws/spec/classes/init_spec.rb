require 'spec_helper'
describe 'jboss_rws' do

  context 'with defaults for all parameters' do
    it { should contain_class('jboss_rws') }
  end
end
