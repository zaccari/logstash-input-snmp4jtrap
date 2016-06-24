module SNMP4JR
  class VariableBinding

    DATE_AND_TIME = 'DateAndTime'
    IPV6_ADDRESS  = 'InetAddressIPv6'

    attr_reader :oid, :value, :variable_binding, :mib_manager

    def initialize(variable_binding)
      @variable_binding = variable_binding
      @mib_manager = MibManager.instance

      @oid   = variable_binding.oid.to_s
      @value = variable_binding.variable.to_s

      format_smi_object if has_smi_syntax?
    end

    private

    def format_smi_object
      # If we have a DateAndTime object, parse it into a usable format.
      if date_and_time_object?
        date_and_time = variable_binding.variable.to_s
        @value = SNMP4JR::DateTimeConverter.new(date_and_time).to_i

      # Addresses are (correctly) rendered like "ab:cd:ef:gh...",
      # we want "abcd:efgh...."
      elsif ipv6_address_object?
        @value = value.gsub(/(..):(..)/,'\1\2')
      end
    end

    def date_and_time_object?
      smi_syntax_clause == DATE_AND_TIME
    end

    def ipv6_address_object?
      smi_syntax_clause == IPV6_ADDRESS
    end

    def has_smi_syntax?
      !smi_object.nil? && !smi_syntax.nil? && !smi_syntax_clause.nil?
    end

    def smi_object
      @smi_object ||= mib_manager.find_smi_object(oid)
    end

    def smi_syntax
      @smi_syntax ||= smi_object.syntax if smi_object.respond_to?(:syntax)
    end

    def smi_syntax_clause
      @smi_syntax_clause ||= smi_syntax.syntax_clause if smi_syntax.respond_to?(:syntax_clause)
    end
  end
end