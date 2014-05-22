require 'gauge'

module Gauge
  module Validators
    class DataTableValidator < ValidatorBase

      def check(table_schema)
        DB::Adapter.session(table_schema.database_name) { |dba| validate(table_schema, dba) }
      end


      def validate(table_schema, dba)
        @dba = dba
        unless table_exists? table_schema
          missing_table table_schema.table_name
        else
          log "Check [#{table_schema.table_name}] data table" do
            errors = []
            table_schema.columns.each do |col|
              errors += DataColumnValidator.new.validate(col, dba)
            end
            errors
          end
        end
      end


  protected
      def validators
        [DataColumnValidator.new]
      end


  private
      def check_missing_table(table_schema)
        errors << "Missing '#{table_schema.table_name}' data table." unless table_exists? table_schema
        errors
      end


      # Determines whether the data table exists in the database.
      def table_exists?(table_schema)
        @dba.tables(schema: table_schema.sql_schema).include?(table_schema.to_key)
      end


      def missing_table(table_name)
        puts "Check [".color(:red) + table_name.color(:red).bright + "] data table - ".color(:red) +
          "missing".color(:red).bright
      end
    end
  end
end
