require 'gauge'

module Gauge
  module Validators
    class MissingColumnValidator < ValidatorBase
      def validate(column_schema, dba)
        unless column_exists? column_schema, dba
          missing_column column_schema.column_name
          return false
        end
        true
      end

  private

      def column_exists?(column_schema, dba)
        dba.schema(column_schema.table_name).any? { |item| item.first == column_schema.to_key }
      end


      def missing_column(column_name)
        errors << "Missing '".color(:red) + column_name.color(:red).bright + "' data column.".color(:red)
      end
    end
  end
end
