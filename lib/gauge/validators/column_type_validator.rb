# Eithery Lab., 2015.
# Class Gauge::Validators::ColumnTypeValidator
# Checks the data column type against the predefined metadata.

require 'gauge'

module Gauge
  module Validators
    class ColumnTypeValidator < Validators::Base

      validate do |column_schema, column, sql|
        if column_schema.data_type != column.data_type
          sql.alter_column column_schema

          errors << "Data column '<b>#{column_schema.column_name}</b>' is '<b>#{column.data_type}</b>', " +
            "but it must be '<b>#{column_schema.data_type}</b>'."
        end
      end
    end
  end
end
