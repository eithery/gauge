require 'gauge'

module Gauge
  class DatabaseInspector
    include ConsoleListener

    def initialize(global_opts, opts, args)
      @args = args
    end


    # Performs check operation for the specified database or database objects
    # against the predefined schema.
    def check
      if @args.any?
        DatabaseValidator.new.check
      else
        error 'No database objects specified to be inspected.'
      end
    end
  end
end
