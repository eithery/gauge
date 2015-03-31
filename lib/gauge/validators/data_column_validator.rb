# Eithery Lab., 2015.
# Class Gauge::Validators::DataColumnValidators
# Checks the specified data column against the predefined metadata.

require 'gauge'

module Gauge
  module Validators
    class DataColumnValidator < Validators::Base
      check_before :missing_column
      check :column_type, :column_length, :column_nullability, :default_constraint,
        with_dbo: ->(table, column_schema) { table.column(column_schema.to_key) }
    end
  end
end
