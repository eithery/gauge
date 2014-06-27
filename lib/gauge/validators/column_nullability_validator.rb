# Eithery Lab., 2014.
# Class Gauge::Validators::ColumnNullabilityValidator
# Checks the data column nullability against the predefined metadata.
require 'gauge'

module Gauge
  module Validators
    class ColumnNullabilityValidator < ValidatorBase

      # Checks the data column nullability.
      def validate(column_schema, db_column)
        if column_schema.allow_null? != db_column[:allow_null]
          should_be = column_schema.allow_null? ? 'NULL' : 'NOT NULL'

          errors << "Data column '".color(:red) + column_schema.column_name.color(:red).bright +
            "' must be defined as #{should_be}.".color(:red)
        end
      end
    end
  end
end
