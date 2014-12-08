# Eithery Lab., 2014.
# Class Gauge::Validators::ColumnNullabilityValidator
# Checks the data column nullability against the predefined metadata.
require 'gauge'

module Gauge
  module Validators
    class ColumnNullabilityValidator < Validators::Base

      validate do |column_schema, db_column|
        if column_schema.allow_null? != db_column.allow_null?
          should_be = column_schema.allow_null? ? 'NULL' : 'NOT NULL'
          errors << "Data column '#{column_schema.column_name}' must be defined as '#{should_be}'."
        end
      end
    end
  end
end
