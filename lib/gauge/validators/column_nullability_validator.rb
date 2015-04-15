# Eithery Lab., 2015.
# Class Gauge::Validators::ColumnNullabilityValidator
# Checks the data column nullability against the predefined metadata.

require 'gauge'

module Gauge
  module Validators
    class ColumnNullabilityValidator < Validators::Base

      validate do |column_schema, column, sql|
        if column_schema.allow_null? != column.allow_null?
          sql.alter_column column_schema

          should_be = column_schema.allow_null? ? 'NULL' : 'NOT NULL'
          errors << "Data column '<b>#{column_schema.column_name}</b>' must be defined as <b>#{should_be}</b>."
        end
      end
    end
  end
end
