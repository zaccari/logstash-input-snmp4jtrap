require 'spec_helper'

RSpec.describe 'SNMP4JR > DATE_TIME > Parse SNMP date-time OID' do

  let(:date_with_zone)    { SNMP4JR::DateTimeConverter.new('07:e0:06:17:0d:18:01:00:2d:04:00') }
  let(:date_without_zone) { SNMP4JR::DateTimeConverter.new('07:e0:06:17:0d:18:01:00') }

  it "passes date-time with time zone" do
    expect(date_with_zone.to_i).to match(1466702641)
    expect(date_with_zone.date).to match("2016-6-23")
    expect(date_with_zone.time).to match("13:24:01.0")
    expect(date_with_zone.zone).to match("-4:0")
    expect(date_with_zone.formatted_zone).to match("-04:00")
    expect(date_with_zone.to_s).to match("2016-6-23,13:24:01.0,-4:0")
  end

  it "passes date-time without time zone" do
    expect(date_without_zone.to_i).to match(1466688241)
    expect(date_without_zone.date).to match("2016-6-23")
    expect(date_without_zone.time).to match("13:24:01.0")
    expect(date_without_zone.zone).to match("+0:0")
    expect(date_without_zone.formatted_zone).to match("+00:00")
    expect(date_without_zone.to_s).to match("2016-6-23,13:24:01.0,+0:0")
  end

end
