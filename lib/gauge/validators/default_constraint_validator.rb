# Eithery Lab., 2014.
# Class Gauge::Validators::DefaultConstraintValidator
# Checks default constraints for data columns.
require 'gauge'

module Gauge
  module Validators
    class DefaultConstraintValidator < Validators::Base
      UID = 'abs(convert(bigint,convert(varbinary,newid())))'

      validate do |column_schema, db_column|
        expected_default = expected_default_value column_schema
        actual_default = column_default column_schema, db_column

        case mismatch expected_default, actual_default
          when :missing_constraint
            errors << column_header_message(column_schema) + missing_constraint_message(expected_default)
          when :constraint_mismatch
            errors << column_header_message(column_schema) +
              constraint_mismatch_message(expected_default, actual_default)
          when :redundant_constraint
            errors << column_header_message(column_schema) + redundant_constraint_message(actual_default)
        end
      end

  private

      def mismatch(expected_default, actual_default)
        return :missing_constraint if !expected_default.nil? && actual_default.nil?
        return :redundant_constraint if expected_default.nil? && !actual_default.nil?
        return :constraint_mismatch unless matched? expected_default, actual_default
      end


      def matched?(expected_default, actual_default)
        return actual_default.to_s =~ uid_pattern if expected_default == UID
        expected_default == actual_default 
      end


      def column_default(column_schema, db_column)
        column_default_value = db_column[:ruby_default]
        column_default_value = db_column[:default] if column_default_value.nil?
        return column_default_value unless column_schema.column_type == :bool
        return false if column_default_value == 0
        true if column_default_value == 1
      end


      def expected_default_value(column_schema)
        default_value = column_schema.default_value
        return UID if default_value == :uid
        default_value
      end


      def bool_column_default
      end


      def missing_constraint_message(expected_value)
        "' - missing default value '".color(:red) + expected_value.to_s.color(:red).bright + "'.".color(:red)
      end


      def constraint_mismatch_message(expected_value, actual_value)
        "' should have '".color(:red) + expected_value.to_s.color(:red).bright +
        "' as default value but actually has '".color(:red) + actual_value.to_s.color(:red).bright +
        "'.".color(:red)
      end


      def redundant_constraint_message(actual_value)
        "' should NOT have default value but actually has '".color(:red) +
        actual_value.to_s.color(:red).bright + "'.".color(:red)
      end


      def column_header_message(column_schema)
        "The column '".color(:red) + column_schema.column_name.to_s.color(:red).bright
      end


      def uid_pattern
        /abs\(convert\(\[bigint\],convert\(\[varbinary\],newid\(\)\)\)\)/i
      end
    end
  end
end
