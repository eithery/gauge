# Eithery Lab., 2017.
# Class Gauge::Helper
# Displays brief help and version information for the application.

require 'gauge'
require_relative 'logger'

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
      info "Database Gauge #{VERSION}"
    end


    def full_info(extended)
      info "Database Gauge. Version #{VERSION}"
      info "Eithery Labs., 2017.\n"
      info "usage: gauge [-v|--version] [-h|--help] [-s|--server] [-u|--user] [-p|--password]"
      info "             [--[no-]colored] <command> [<args>] [<command options>]"
      if extended
        info "\nThe most commonly used gauge commands are:"
        info "   check    Checks database structure against the metadata"
        info "   sync     Synchronize database structure regarding the metadata"
        info "   help     Displays additional help info"
        info "\nSee 'g help <command>' for more information on a specific command."
      end
    end
  end
end
