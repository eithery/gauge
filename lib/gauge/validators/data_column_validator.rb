require 'gauge'

module Gauge
  module Validators
    class DataColumnValidator < ValidatorBase
      def initialize(db_adapter)
        @dba = db_adapter
      end


      def check(column_schema)
        unless column_exists? column_schema
          [missing_column(column_schema.column_name)]
        else
          @column_name = column_schema.column_name
          @options = @dba.schema(column_schema.table_name).select { |item| item.first == column_schema.to_key }.first.last

          errors = []
          if column_schema.allow_null? != allow_null?
            should_be = column_schema.allow_null? ? 'NULL' : 'NOT NULL'
            errors << "Data column '".color(:red) + @column_name.color(:red).bright +
              "' must be defined as #{should_be}.".color(:red)
          end
          if column_schema.data_type != data_type
            errors << "Data column '".color(:red) + @column_name.color(:red).bright +
              "' is '#{data_type}' but it must be '#{column_schema.data_type}'.".color(:red)
          end
          errors
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


      # Determines whether data column allows NULL value.
      def allow_null?
        @options[:allow_null]
      end


      # Column data type.
      def data_type
        @options[:db_type]
      end
    end
  end
end
