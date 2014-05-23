require 'gauge'

module Gauge
  module Validators
    class MissingColumnValidator < ValidatorBase
      def validate(column_schema, dba)
        unless dba.column_exists? column_schema
          missing_column column_schema.column_name
          return false
        end
        true
      end

  private

      def missing_column(column_name)
        errors << "Missing '".color(:red) + column_name.color(:red).bright + "' data column.".color(:red)
      end
    end
  end
end
