require 'gauge'

module Gauge
  module Validators
    class MissingColumnValidator < ValidatorBase
      def validate(column_schema, dba)
        table_name = column_schema.table_name
        unless dba.schema(table_name).any? { |item| item.first == column_schema.to_key }
          errors << "Missing '".color(:red) + column_schema.column_name.color(:red).bright +
            "' data column.".color(:red)
        end
      end
    end
  end
end
