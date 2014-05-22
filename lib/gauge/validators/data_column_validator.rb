require 'gauge'

module Gauge
  module Validators
    class DataColumnValidator < ValidatorBase

      def validate(column_schema, dba)
        unless missing_column? column_schema, dba
          db_column = dba.schema(column_schema.table_name).select { |item| item.first == column_schema.to_key }.first.last
          super(column_schema, db_column)
        end
        errors
      end

  protected

      def validators
        [ColumnNullabilityValidator.new, ColumnTypeValidator.new]
      end


  private
      def missing_column?(column_schema, dba)
        mcv = MissingColumnValidator.new
        mcv.validate column_schema, dba
        errors.concat(mcv.errors)
        mcv.errors.any?
      end
    end
  end
end
