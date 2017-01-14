# Eithery Lab, 2017
# Class Gauge::Shell
# Executes application commands.

require 'gauge'

module Gauge
  class Shell
    def initialize
      Rainbow.enabled = true
    end


    def help(options)
      Helper.new(options).application_info
    end


    def check(options, args)
      Inspector.new(options).check args
    end
  end
end
