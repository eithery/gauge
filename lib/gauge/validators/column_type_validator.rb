# Eithery Lab., 2014.
# Class Gauge::Validators::ColumnTypeValidator
# Checks the data column type against the predefined metadata.
require 'gauge'

module Gauge
  module Validators
    class ColumnTypeValidator < Validators::Base

      validate do |column_schema, db_column|
        if column_schema.data_type != db_column.data_type
          errors << "Data column '<b>#{column_schema.column_name}</b>' is '<b>#{db_column.data_type}</b>', " +
            "but it must be '<b>#{column_schema.data_type}</b>'."
        end
      end
    end
  end
end
