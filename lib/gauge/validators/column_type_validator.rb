# Eithery Lab., 2014.
# Class Gauge::Validators::ColumnTypeValidator
# Checks the data column type against the predefined metadata.
require 'gauge'

module Gauge
  module Validators
    class ColumnTypeValidator < Validators::Base

      validate do |column_schema, db_column|
        if column_schema.data_type != db_column.data_type
          errors << "Data column '#{column_schema.column_name}' is '#{db_column.data_type}', " +
            "but it must be '#{column_schema.data_type}'."
        end
      end
    end
  end
end
