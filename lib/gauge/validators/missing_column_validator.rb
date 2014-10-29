# Eithery Lab., 2014.
# Class Gauge::Validators::MissingColumnValidator
# Performs check for missing data column.
require 'gauge'

module Gauge
  module Validators
    class MissingColumnValidator < ValidatorBase

      # Checks for missing data column.
      def validate(column_schema, dba)
        unless dba.column_exists? column_schema
          missing_column column_schema.column_name
          return false
        end
        true
      end

  private

      def missing_column(column_name)
        errors << "Missing '".color(:red) + column_name.to_s.color(:red).bright + "' data column.".color(:red)
      end
    end
  end
end
