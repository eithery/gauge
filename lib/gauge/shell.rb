# Eithery Lab., 2014.
# Class Gauge::Shell
# Executes application commands.
require 'gauge'

module Gauge
  class Shell
    def initialize
      Rainbow.enabled = true
    end


    def help(global_opts)
      Helper.new(global_opts).application_info
    end


    def check(*args)
      DatabaseInspector.new(*args).check
    end
  end
end
