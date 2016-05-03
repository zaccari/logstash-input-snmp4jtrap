require 'spec_helper'

describe Logstash::Input::Snmp4jtrap do
  it 'has a version number' do
    expect(Logstash::Input::Snmp4jtrap::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
