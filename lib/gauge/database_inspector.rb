require 'gauge'

module Gauge
  class DatabaseInspector
    include ConsoleListener

    def initialize(global_opts, options, args)
      @repo = Repo.new
      @args = args
      @connection = DB::Connection.new(global_opts)
    end


    # Validates the specified database or database objects structure against the predefined schema.
    def check
      if @args.empty?
        error 'No database objects specified to be inspected.'
        return
      end

      @args.each do |dbo|
        Sequel.tinytds(dataserver: @connection.server, database: @repo.schema(dbo).database_name,
          user: @connection.user, password: @connection.password) do |db_adapter|

          db_adapter.test_connection

          if @repo.database? dbo
            Validators::DatabaseValidator.new(db_adapter).check(@repo.schema dbo)
          elsif @repo.table? dbo
            Validators::TableValidator.new(db_adapter).check(@repo.schema dbo)
          else
            error "Database metadata for '#{dbo}' is not found."
          end

        end
      end
    end
  end
end
