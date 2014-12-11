# Eithery Lab., 2014.
# Class Gauge::Validators::MissingColumnValidator
# Performs check for missing data column.
require 'gauge'

module Gauge
  module Validators
    class MissingColumnValidator < Validators::Base

      validate do |column, dba|
        result = true
        unless dba.column_exists? column
          missing_column column.column_name
          result = false

          build_sql(:add_column, column) do |sql|
            sql.alter_table column.table
            sql.add_column column
          end
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
