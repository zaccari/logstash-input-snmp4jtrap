require 'snmp4j-smi-pro.jar'

module SNMP4JR
  module SMI
    include_package 'com.snmp4j.smi'

    module Util
      include_package 'com.snmp4j.smi.util'
    end
  end
end
