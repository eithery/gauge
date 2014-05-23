require 'gauge'

module Gauge
  module Validators
    class MissingTableValidator < ValidatorBase
      def validate(table_schema, dba)
        unless dba.table_exists? table_schema
          missing_table table_schema.table_name
          return false
        end
        true
      end

  private

      def missing_table(table_name)
        message = "Check [".color(:red) + table_name.color(:red).bright + "] data table - ".color(:red) +
          "missing".color(:red).bright
        errors << message
        puts message
      end
    end
  end
end
