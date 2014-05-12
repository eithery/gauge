require 'gauge'

module Gauge
  module Validators
    class TableValidator
      include ConsoleListener

      def initialize(db_adapter)
        @dba = db_adapter
      end


      def check(table_schema)
        log "Inspecting #{table_schema.table_name} data table" do
          check_missing_table table_schema
        end
      end

  private
      def check_missing_table(table_schema)
        errors = []
        errors << "Missing '#{table_schema.table_name}' data table." unless table_exists? table_schema
        errors
      end


      # Determines whether the data table exists in the database.
      def table_exists?(table_schema)
        @dba.tables(schema: table_schema.sql_schema).include?(table_schema.to_key)
      end
    end
  end
end
