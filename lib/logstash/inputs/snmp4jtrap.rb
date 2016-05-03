# encoding: utf-8
require 'logstash/inputs/base'
require 'logstash/namespace'

# Read snmp trap messages as events with optional custom MIB support.

class LogStash::Inputs::Snmp4JTrap < LogStash::Inputs::Base
  config_name 'snmp4jtrap'

  # The address to listen on
  config :host, validate: :string, default: '0.0.0.0'

  # The port to listen on. Remember that ports less than 1024 (privileged
  # ports) may require root to use. hence the default of 10162.
  config :port, validate: :number, default: 1162

  # Transport protocol
  config :protocol, validate: ['udp', 'tcp'], default: 'udp'

  # Directory containing MIB files
  config :mib_dir, validate: :string, default: '/usr/share/snmp/mibs'

  # SNMP4J-SMI PRO License Key
  config :license_key, validate: :string

  def initialize(*args)
    super(*args)
  end # def initialize

  def register
    require 'snmp4jr'
    @snmptrap = nil
    load_mib_manager
  end

  def run(output_queue)
    begin
      snmptrap_listener(output_queue)
    rescue => e
      @logger.warn('SNMP4J Trap listener died', exception: e, backtrace: e.backtrace)
      Stud.stoppable_sleep(5) { stop? }
      retry if !stop?
    end
  end

  def stop
    @snmptrap.close if @snmptrap
    @snmptrap = nil
  end

  private

  def load_mib_manager
    @mib_manager = SNMP4JR::MibManager.instance

    @mib_manager.license_key = @license_key
    @mib_manager.mib_directory = @mib_dir

    @mib_manager.load
  end

  def build_trap_listener
    listener_opts = {
      protocol: @protocol,
      host: @host,
      port: @port
    }

    @logger.info("It's a Trap!", listener_opts.dup)

    @snmptrap = SNMP4JR::TrapListener.new(listener_opts)
  end

  def snmptrap_listener(output_queue)
    build_trap_listener

    @snmptrap.on_trap do |trap|
      begin
        event = LogStash::Event.new(trap.to_h)
        decorate(event)
        @logger.debug('SNMP Trap received: ', trap_object: trap.inspect)
        output_queue << event
      rescue => error
        @logger.error('Failed to create event', trap_object: trap.inspect)
      end
    end

    @snmptrap.join
  end
end
