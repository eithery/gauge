require 'gauge'

module Gauge
  module Validators
    class DataColumnValidator < ValidatorBase

      def validate(column_schema, dba)
        if before_validate column_schema, dba
          db_column = dba.schema(column_schema.table_name).select { |item| item.first == column_schema.to_key }.first.last
          super(column_schema, db_column)
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
