module SNMP4JR
  class Message

    attr_reader :event, :data

    def initialize(event)
      @event = event
      parse_event
    end

    def to_h
      data
    end
    alias_method :to_hash, :to_h

    def [](oid)
      data[oid]
    end

    private

    def parse_event
      @data = {
        'snmp_request_id' => request_id,
        'peer_address'    => peer_address,
        'host'            => peer_address
      }

      variable_bindings.each do |variable|
        @data[variable.oid] = variable.value
      end

      @data
    end

    def variable_bindings
      pdu.variable_bindings.map { |vb| VariableBinding.new(vb) }
    end

    def pdu
      @pdu ||= event.pdu
    end

    def request_id
      @request_id ||= pdu.request_id.toInt
    end

    def peer_address
      @peer_address ||= event.peer_address.toString
    end
  end
end