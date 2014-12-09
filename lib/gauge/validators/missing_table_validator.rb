# Eithery Lab., 2014.
# Class Gauge::Validators::MissingTableValidator
# Performs check for missing data table.
require 'gauge'

module Gauge
  module Validators
    class MissingTableValidator < Validators::Base

      validate do |table_schema, dba|
        result = true
        unless dba.table_exists? table_schema
          missing_table table_schema.table_name
          result = false
        end
        result
      end

  private

      def missing_table(table_name)
        errors << "'<b>#{table_name}</b>' data table does not exist."
      end
    end
  end
end
