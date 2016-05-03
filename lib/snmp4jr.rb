require 'java'
require 'snmp4j-2.3.0.jar'
require 'snmp4j-agent-2.2.2.jar'

module SNMP4JR
  include_package 'org.snmp4j'

  module Agent
    module MO
      module Snmp
        include_package 'org.snmp4j.agent.mo.snmp'
      end
    end
  end

  module ASN1
    include_package 'org.snmp4j.asn1'
  end

  module Event
    include_package 'org.snmp4j.event'
  end

  module Log
    include_package 'org.snmp4j.log'
  end

  module MP
    include_package 'org.snmp4j.mp'
  end

  module Security
    include_package 'org.snmp4j.security'
  end

  module SMI
    include_package 'org.snmp4j.smi'

    module Util
      include_package 'org.snmp4j.smi.util'
    end
  end

  module Transport
    include_package 'org.snmp4j.transport'
  end

  module Util
    include_package 'org.snmp4j.util'
  end

  module Version
    include_package 'org.snmp4j.version'
  end
end

require 'snmp4jr/mib_manager'
require 'snmp4jr/variable_binding'
require 'snmp4jr/message'
require 'snmp4jr/trap_listener'