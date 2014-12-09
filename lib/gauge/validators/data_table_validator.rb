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
        errors.clear
        super(table_schema, dba)
        print_totals table_schema
      end

  private

      def print_totals(table_schema)
        if errors.empty?
          ok "Check '#{table_schema.table_name}' data table - <b>ok</b>"
        else
          error "Check '<b>#{table_schema.table_name}</b>' data table - failed"
          error "Errors:"
          errors.each { |msg| error "- #{msg}" }
          error "Total #{errors.count} errors found.\n"
        end
      end
    end
  end
end
