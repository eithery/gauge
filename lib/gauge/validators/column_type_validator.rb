# Eithery Lab., 2014.
# Class Gauge::Validators::ColumnTypeValidator
# Checks the data column type against the predefined metadata.
require 'gauge'

module Gauge
  module Validators
    class ColumnTypeValidator < ValidatorBase

      # Checks the data column type.
      def validate(column_schema, db_column)
        data_type = db_column[:db_type]
        if column_schema.data_type != data_type
          errors << "Data column '".color(:red) + column_schema.column_name.color(:red).bright +
            "' is '#{data_type}' but it must be '#{column_schema.data_type}'.".color(:red)
        end
      end
    end
  end
end