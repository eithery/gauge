# Eithery Lab., 2014.
# Class Gauge::Validators::ColumnNullabilityValidator
# Checks the data column nullability against the predefined metadata.
require 'gauge'

module Gauge
  module Validators
    class ColumnNullabilityValidator < Validators::Base

      validate do |column_schema, db_column|
        if column_schema.allow_null? != db_column.allow_null?
          build_sql(:alter_column, column_schema) do |sql|
            sql.alter_table column_schema.table
            sql.alter_column column_schema
          end

          should_be = column_schema.allow_null? ? 'NULL' : 'NOT NULL'
          errors << "Data column '<b>#{column_schema.column_name}</b>' must be defined as <b>#{should_be}</b>."
        end
      end
    end
  end
end
