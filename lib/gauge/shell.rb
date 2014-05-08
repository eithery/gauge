# Eithery Lab., 2014.
# Class Gauge::Shell
# Executes application commands.
module Gauge
  class Shell
    attr_reader :listeners

    def initialize(global_opts={}, options={})
      @global_opts = global_opts
      @options = options
      Rainbow.enabled = true
    end


    def help
      h = Helper.new
      @global_opts[:v] ? h.version : h.application_info(@global_opts[:h])
    end


    # Performs check operation for the specified database or separate database objects
    # against the predefined schema.
    def check(args)
      dbos = args.respond_to?(:each) ? args : [args]
      dbos.each do |dbo|
      end
    end
  end
end
