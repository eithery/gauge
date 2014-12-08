# Eithery Lab., 2014.
# Class Gauge::Validators::DataTableValidator
# Checks the specified data table structure against the predefined schema.
require 'gauge'

module Gauge
  module Validators
    class DataTableValidator < Validators::Base
      check_before :missing_table
      check_all(:data_columns) { |table_schema| table_schema.columns }

      def check(table_schema, dba)
        with_log "Check '#{table_schema.table_name}' data table" do
          errors.clear
          super(table_schema, dba)
          errors
        end
      end
    end
  end
end
