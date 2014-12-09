# Eithery Lab., 2014.
# Class Gauge::Validators::DefaultConstraintValidator
# Checks default constraints for data columns.
require 'gauge'

module Gauge
  module Validators
    class DefaultConstraintValidator < Validators::Base
      validate do |column_schema, db_column|
        actual_default_value = column_default column_schema, db_column

        case mismatch column_schema.default_value, actual_default_value
          when :missing_constraint
            errors << column_header_message(column_schema) + missing_constraint_message(column_schema.default_value)
          when :constraint_mismatch
            errors << column_header_message(column_schema) +
              constraint_mismatch_message(column_schema.default_value, actual_default_value)
          when :redundant_constraint
            errors << column_header_message(column_schema) + redundant_constraint_message(actual_default_value)
        end
      end

  private

      def mismatch(expected_default, actual_default)
        return :missing_constraint if !expected_default.nil? && actual_default.nil?
        return :redundant_constraint if expected_default.nil? && !actual_default.nil?
        :constraint_mismatch unless matched? expected_default, actual_default
      end


      def matched?(expected_default, actual_default)
        return actual_default.to_s =~ uid_pattern if expected_default == Schema::DataColumnSchema::UID
        actual_default == expected_default
      end


      def column_default(column_schema, db_column)
        column_schema.bool? ? convert_to_bool(db_column.default_value) : db_column.default_value
      end


      def convert_to_bool(column_default_value)
        case column_default_value
          when 0 then false
          when 1 then true
        end
      end


      def missing_constraint_message(expected_value)
        " - missing default value '<b>#{expected_value}</b>'."
      end


      def constraint_mismatch_message(expected_value, actual_value)
        " should have '<b>#{expected_value}</b>' as default value, but actually has '<b>#{actual_value}</b>'."
      end


      def redundant_constraint_message(actual_value)
        " should NOT have default value, but actually has '<b>#{actual_value}</b>'."
      end


      def column_header_message(column_schema)
        "The column '<b>#{column_schema.column_name}</b>'"
      end


      def uid_pattern
        /abs\(convert\(\[bigint\],convert\(\[varbinary\],newid\(\)\)\)\)/i
      end
    end
  end
end
