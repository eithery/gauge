require 'gauge'

module Gauge
  module Validators
    class DataColumnValidator < ValidatorBase

      def validate(column_schema, dba)
        super(column_schema, dba) do
          super(column_schema, dba.data_column(column_schema))
        end
        errors
      end

  protected

      def before_validators
        [MissingColumnValidator.new]
      end


      def validators
        [ColumnNullabilityValidator.new, ColumnTypeValidator.new]
      end
    end
  end
end
