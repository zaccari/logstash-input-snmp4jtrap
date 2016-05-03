require 'singleton'
require 'snmp4jr-smi-pro'

module SNMP4JR
  class MibManager
    include ::Singleton

    attr_accessor :license_key, :mib_directory

    attr_reader :compilation_monitor, :load_into_repository, :update_existent,
      :compile_leniently

    def initialize
      @compilation_monitor = nil
      @load_into_repository = true
      @update_existent = true
      @compile_leniently = false
    end

    def load
      return if loaded? || license_key.nil? || mib_directory.nil?
      compile_mibs
      set_formats
      @loaded = true
    end

    def loaded?
      @loaded == true
    end

    # http://www.snmp4j.org/smi/doc/com/snmp4j/smi/SmiManager.html#findSmiObject(org.snmp4j.smi.OID)
    def find_smi_object(oid)
      return nil unless loaded?
      manager.find_smi_object(SNMP4JR::SMI::OID.new(oid))
    end

    private

    # The SmiManager Pro class manages the Structure of Management Information
    # (SMI) specifications. SMIv1 and v2 MIB modules can be parsed and compiled
    # to a MIB repository which provides its content to SNMP4J through a OID and
    # Variable formatter and parser.
    def manager
      @manager ||= SNMP4JR::SMI::SmiManager.new(license_key, driver)
    end

    # MemRepositoryDriver stores all MIB modules in memory.
    # http://www.snmp4j.org/smi/doc/com/snmp4j/smi/util/MemRepositoryDriver.html
    def driver
      @driver ||= SNMP4JR::SMI::Util::MemRepositoryDriver.new
    end

    def compile_mibs
      results = manager.compile(mib_list,
                                compilation_monitor,
                                load_into_repository,
                                update_existent,
                                compile_leniently)

      results.each do |result|
        smi_errors = result.smi_error_list
        file_name  = result.file_name.to_s.split('/').last
        last_file  = nil

        if last_file.nil? || last_file != file_name
          debug "------ #{file_name} ------"
          last_file = file_name
        end

        if smi_errors.nil?
          debug ">>> OK: #{file_name}"
        else
          smi_errors.size.to_i.times do |i|
            debug ">>> ERROR: #{file_name} ##{i + 1}: #{smi_errors.get(i).message}"
          end
        end
      end

      manager.list_modules.each do |mod|
        debug "Loaded SNMP module '#{mod}'"
      end
    end

    def set_formats
      SNMP4JR::SNMP4JSettings.setOIDTextFormat(manager)
      SNMP4JR::SNMP4JSettings.setVariableTextFormat(manager)
    end

    def mib_list
      java.io.File.new(mib_directory).list_files
    end

    def debug(message = '')
      puts(message) if debug?
    end

    def debug?
      !ENV['DEBUG'].nil?
    end
  end
end