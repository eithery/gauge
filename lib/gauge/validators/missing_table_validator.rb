# Eithery Lab., 2014.
# Class Gauge::Validators::MissingTableValidator
# Performs check for missing data table.
require 'gauge'

module Gauge
  module Validators
    class MissingTableValidator < ValidatorBase

      # Checks for missing data table.
      def validate(table_schema, dba)
        unless dba.table_exists? table_schema
          missing_table table_schema.table_name
          return false
        end
        true
      end

  private

      def missing_table(table_name)
        message = "Check [".color(:red) + table_name.color(:red).bright + "] data table - ".color(:red) +
          "missing".color(:red).bright
        errors << message
        puts message
      end
    end
  end
end
