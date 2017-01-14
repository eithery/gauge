# Eithery Lab, 2017
# Class Gauge::Helper
# Displays brief help and version information for the application.

require 'gauge'
require_relative 'logger'
require_relative 'version'

module Gauge
  class Helper
    include Logger

    def initialize(options={})
      @options = options
      Logger.configure(colored: options[:colored])
    end


    def application_info
      @options[:v] ? version : full_info(@options[:h])
    end


  private

    def version
      info "Gauge #{VERSION}"
    end


    def full_info(extended)
      info HEADER
      info COMMANDS if extended
    end


    HEADER = <<~eos
      Gauge. Version #{VERSION}
      SQL server database command line tool.
      Eithery Labs., 2017
      usage: gauge [-v|--version] [-h|--help] [-s|--server] [-u|--user] [-p|--password]
                   [--[no-]colored] <command> [<args>] [<command options>]
    eos


    COMMANDS = <<~eos
      The most commonly used gauge commands are:
          check    Checks database structure against the metadata
          sync     Synchronize database structure regarding the metadata
          help     Displays additional help info

      See 'gauge help <command>' for more information on a specific command.
    eos
  end
end
