require 'gauge'

module Gauge
  module Validators
    class MissingTableValidator < ValidatorBase
      def validate(table_schema, dba)
        unless table_exists? table_schema, dba
          missing_table table_schema.table_name
          return false
        end
        true
      end

  private

      def table_exists?(table_schema, dba)
        dba.tables(schema: table_schema.sql_schema).include?(table_schema.to_key)
      end


      def missing_table(table_name)
        message = "Check [".color(:red) + table_name.color(:red).bright + "] data table - ".color(:red) +
          "missing".color(:red).bright
        errors << message
        puts message
      end
    end
  end
end
