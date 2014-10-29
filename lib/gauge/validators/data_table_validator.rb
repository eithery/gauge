# Eithery Lab., 2014.
# Class Gauge::Validators::DataTableValidator
# Checks the specified data table structure against the predefined schema.
require 'gauge'

module Gauge
  module Validators
    class DataTableValidator < ValidatorBase

      # Performs data table validation check.
      def check(table_schema)
        DB::Adapter.session(table_schema.database_name) { |dba| validate(table_schema, dba) }
      end


      # Validates the data table structure.
      def validate(table_schema, dba)
        super(table_schema, dba) do
          log "Check #{table_schema.table_name} data table" do
            self.errors.clear
            table_schema.columns.each { |col| super(col, dba) }
            self.errors
          end
        end
      end


  protected

      # Child validators called before the main validation cycle.
      def before_validators
        [MissingTableValidator.new]
      end


      # Child validators.
      def validators
        [DataColumnValidator.new]
      end
    end
  end
end
