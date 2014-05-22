require 'gauge'

module Gauge
  module Validators
    class ColumnNullabilityValidator < ValidatorBase
      def validate(column_schema, db_column)
        if column_schema.allow_null? != db_column[:allow_null]
          should_be = column_schema.allow_null? ? 'NULL' : 'NOT NULL'

          errors << "Data column '".color(:red) + column_schema.column_name.color(:red).bright +
            "' must be defined as #{should_be}.".color(:red)
        end
      end
    end
  end
end
