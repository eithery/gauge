# Eithery Lab., 2014.
# Class Gauge::Shell
# Executes application commands.
require 'gauge'

module Gauge
  class Shell
    def initialize
      Rainbow.enabled = true
    end


    # Displays help info about the application and available commands.
    def help(global_opts)
      Helper.new(global_opts).application_info
    end


    # Validates the specified database or particular database objects
    # against the predefined schema.
    def check(*args)
      DatabaseInspector.new(*args).check
    end
  end
end
