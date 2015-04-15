# Eithery Lab., 2015.
# Class Gauge::Validators::DataTableValidator
# Checks the specified data table structure against the predefined schema.

require 'gauge'

module Gauge
  module Validators
    class DataTableValidator < Validators::Base
      check_before :missing_table
      check :primary_key, :indexes, :unique_constraints,
        with_dbo: ->(database, table_schema) { database.table table_schema.table_name }
      check_all :data_columns, with_schema: ->table { table.columns },
        with_dbo: ->(database, table_schema) { database.table table_schema.table_name }

      def check(table_schema, database)
        errors.clear
        sql = SQL::Builder.new
        sql.cleanup table_schema
        super(table_schema, database, sql)
        print_totals table_schema
      end

  private

      def print_totals(table_schema)
        if errors.empty?
          ok "Check '#{table_schema.table_name}' data table - <b>ok</b>"
        else
          error "Check '<b>#{table_schema.table_name}</b>' data table - <b>failed</b>"
          error "Errors:"
          errors.each { |msg| error "-- #{msg}" }
          error "Total #{errors.count} errors found."
          error ""
        end
      end
    end
  end
end
