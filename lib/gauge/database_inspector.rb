# Eithery Lab., 2014.
# Class Gauge::DatabaseInspector
# Performs various validation checks of the specified database or
# particular database objects structure against the predefined schema.
require 'gauge'

module Gauge
  class DatabaseInspector
    include ConsoleListener

    def initialize(global_opts, options, args)
      @args = args
      DB::Connection.configure global_opts
    end


    def check
      if @args.empty?
        error 'No database objects specified to be inspected.'
        return
      end

      repo = Repo.new
      @args.each { |dbo| repo.validate dbo }
    end
  end
end
