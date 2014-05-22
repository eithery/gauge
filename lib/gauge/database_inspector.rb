require 'gauge'

module Gauge
  class DatabaseInspector
    include ConsoleListener

    def initialize(global_opts, options, args)
      if args.empty?
        error 'No database objects specified to be inspected.'
        return
      end

      @args = args
      DB::Connection.configure global_opts
    end


    # Validates the specified database or database objects structure against the predefined schema.
    def check
      repo = Repo.new
      @args.each { |dbo| repo.validate dbo }
    end
  end
end
