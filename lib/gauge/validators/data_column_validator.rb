require 'gauge'

module Gauge
  module Validators
    class DataColumnValidator
      include ConsoleListener

      def initialize(db_adapter)
        @dba = db_adapter
      end


      def check(column_schema)
        unless column_exists? column_schema
          [missing_column(column_schema.column_name)]
        else
          []
        end
      end


  private
      def column_exists?(column_schema)
        table_name = column_schema.table_name
        @dba.schema(table_name).any? { |item| item.first == column_schema.to_key }
      end


      def missing_column(column_name)
        "Missing '".color(:red) + column_name.color(:red).bright + "' data column.".color(:red)
      end
    end
  end
end
