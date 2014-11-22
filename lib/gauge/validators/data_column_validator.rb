# Eithery Lab., 2014.
# Class Gauge::Validators::DataColumnValidators
# Checks the specified data column against the predefined metadata.
require 'gauge'

module Gauge
  module Validators
    class DataColumnValidator < Validators::Base
      check_before :missing_column
      check :column_nullability, :column_type, :column_length, :default_constraint do |column_schema, dba|
        dba.column(column_schema)
      end
    end
  end
end
