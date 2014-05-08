# Eithery Lab., 2014.
# Class Gauge::Helper
# Displays brief help and version information for the app.
require 'gauge'

module Gauge
  class Helper
    include ConsoleListener

    def version
      info "Database Gauge #{VERSION}"
    end


    def application_info(extended)
      info "Database Gauge. Version #{VERSION}"
      info "Copyright (C) M&O Systems, Inc., 2014.\n"
      info "usage: g [--version|-v] [--help|-h] <command> [<args>]"
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
