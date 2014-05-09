require 'gauge'

module Gauge
  class DatabaseInspector
    include ConsoleListener

    def initialize(global_opts, opts, args)
      @repo = Repo.new
      @args = args
    end


    # Performs check operation for the specified database or database objects
    # against the predefined schema.
    def check
      if @args.empty?
        error 'No database objects specified to be inspected.'
        return
      end

      @args.each do |dbo|
        if @repo.database? dbo
          Validators::DatabaseValidator.new.check(@repo.schema dbo)
        elsif @repo.table? dbo
          Validators::TableValidator.new.check(@repo.schema dbo)
        else
          error "Database metadata for '#{dbo}' is not found."
        end
      end
    end
  end
end
