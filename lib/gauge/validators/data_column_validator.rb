# Eithery Lab., 2014.
# Class Gauge::Validators::DataColumnValidators
# Checks the specified data column against the predefined metadata.
require 'gauge'

module Gauge
  module Validators
    class DataColumnValidator < ValidatorBase

      # Performs validation check for the specified data column.
      def validate(column_schema, dba)
        super(column_schema, dba) do
          super(column_schema, dba.data_column(column_schema))
        end
        errors
      end


  protected

      # Child validators called before the main validation cycle.
      def before_validators
        [MissingColumnValidator.new]
      end


      # Child validators.
      def validators
        [ColumnNullabilityValidator.new, ColumnTypeValidator.new]
      end
    end
  end
end
