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

      Schema::Repo.load
      @args.each do |dbo|
        validator = validator_for dbo
        validator.check(Schema::Repo.schema dbo) unless validator.nil?
      end
    end

private

    def validator_for(dbo)
      return Validators::DatabaseValidator.new if Schema::Repo.database? dbo
      return Validators::DataTableValidator.new if Schema::Repo.table? dbo

      error "Database metadata for '#{dbo}' is not found."
    end
  end
end


#      def perform_check(database_schema)
#        info "Inspecting '#{database_schema.database_name.to_s}' database ..."
#        DB::Adapter.session(database_schema.sql_name) do |dba|
#          database_schema.tables.values.each { |table| validate table, dba }
#        end
#      end

#      def perform_check(table_schema)
#        DB::Adapter.session(table_schema.database_name) { |dba| validate(table_schema, dba) }
#      end
#      def validate(table_schema, dba)
#        log "Check #{table_schema.table_name} data table" do
#          self.errors.clear
#          table_schema.columns.each { |col| super(col, dba) }
#          self.errors
#        end
#      end
