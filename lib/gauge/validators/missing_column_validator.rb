# Eithery Lab., 2014.
# Class Gauge::Validators::MissingColumnValidator
# Performs check for missing data column.
require 'gauge'

module Gauge
  module Validators
    class MissingColumnValidator < Validators::Base

      validate do |column_schema, dba|
        result = true
        unless dba.column_exists? column_schema
          missing_column column_schema.column_name
          result = false
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
