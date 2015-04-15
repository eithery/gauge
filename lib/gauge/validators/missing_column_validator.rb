# Eithery Lab., 2015.
# Class Gauge::Validators::MissingColumnValidator
# Performs check for missing data column.

require 'gauge'

module Gauge
  module Validators
    class MissingColumnValidator < Validators::Base

      validate do |column_schema, table, sql|
        result = true
        unless table.column_exists? column_schema.to_sym
          missing_column column_schema.column_name
          result = false

#          sql.build_sql(:add_column, column_schema) do |sql|
#            sql.alter_table column_schema.table
#            sql.add_column column_schema
#          end
        end
        result
      end

  private

      def missing_column(column_name)
        errors << "Data column '<b>#{column_name}</b>' does <b>NOT</b> exist."
      end
    end
  end
end
