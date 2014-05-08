# Eithery Lab., 2014.
# Class Gauge::Shell
# Executes application commands.
module Gauge
  class Shell
    attr_reader :listeners

    def initialize
      Rainbow.enabled = true
    end


    def help(*args)
      Helper.new(*args).application_info
    end


    # Performs check operation for the specified database or separate database objects
    # against the predefined schema.
    def check(*args)
      Inspector.new(*args).check
    end
  end
end
