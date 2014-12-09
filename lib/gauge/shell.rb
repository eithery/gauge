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


    def check(global_opts, opts, args)
      Inspector.new(global_opts, opts).check args
    end
  end
end
