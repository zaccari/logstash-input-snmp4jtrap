module SNMP4JR
  class TrapListener
    def initialize(options = {})
      @protocol       = options[:protocol] || 'udp'
      @host           = options[:host]     || '127.0.0.1'
      @port           = options[:port]     || 1162
      @done           = false
      @lock           = Mutex.new
      @trap_handler   = Proc.new {}
      @handler_thread = Thread.new { process_traps }
    end

    def on_trap(&block)
      raise ArgumentError, 'a block must be provided' unless block
      @lock.synchronize { @trap_handler = block }
    end

    def join
      @handler_thread.join
    end

    def process_pdu(event)
      begin
        @trap_handler.call(Message.new(event))
      rescue => e
        puts "Error handling trap: #{e.message}"
        puts e.backtrace.join("\n")
        puts "Event:"
        p event
      end
    end
    alias_method :processPdu, :process_pdu

    def close
      @snmp.close if @snmp
      @done = true
      @handler_thread.join
    end

    alias_method :exit, :close
    alias_method :kill, :close
    alias_method :terminate, :close

    private

    def process_traps
      snmp.add_notification_listener(address, self)
      snmp.listen

      # TODO: Come up with a better way to block here
      until @done
        sleep 0.5
      end
    end

    def snmp
      @snmp ||= SNMP4JR::Snmp.new(transport)
    end

    def transport
      @transport ||= begin
        if @protocol == 'tcp'
          SNMP4JR::Transport::DefaultTcpTransportMapping.new
        else
          SNMP4JR::Transport::DefaultUdpTransportMapping.new
        end
      end
    end

    def address
      @address ||= SNMP4JR::SMI::GenericAddress.parse("#{@protocol}:#{@host}/#{@port}")
    end
  end
end