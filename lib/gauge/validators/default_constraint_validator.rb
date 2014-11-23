# Eithery Lab., 2014.
# Class Gauge::Validators::DefaultConstraintValidator
# Checks default constraints for data columns.
require 'gauge'

module Gauge
  module Validators
    class DefaultConstraintValidator < Validators::Base
      validate do |column_schema, db_column|
        actual_default = column_default column_schema, db_column
        case mismatch column_schema.default_value, actual_default
          when :missing_constraint
            errors << column_header_message(column_schema) + missing_constraint_message(column_schema.default_value)
          when :constraint_mismatch
            errors << column_header_message(column_schema) +
              constraint_mismatch_message(column_schema.default_value, actual_default)
          when :redundant_constraint
            errors << column_header_message(column_schema) + redundant_constraint_message(actual_default)
        end
      end

  private

      def mismatch(expected_default, actual_default)
        return :missing_constraint if !expected_default.nil? && actual_default.nil?
        return :redundant_constraint if expected_default.nil? && !actual_default.nil?
        return :constraint_mismatch unless expected_default == actual_default
      end


      def column_default(column_schema, db_column)
        column_default_value = db_column[:ruby_default]
        return column_default_value unless column_schema.column_type == :bool
        return false if column_default_value == 0
        true if column_default_value == 1
      end


      def missing_constraint_message(expected_value)
        "' - missing default value '".color(:red) + expected_value.to_s.color(:red).bright + "'.".color(:red)
      end


      def constraint_mismatch_message(expected_value, actual_value)
        "' should have '".color(:red) + expected_value.to_s.color(:red).bright +
        "' default value but actually has '".color(:red) + actual_value.to_s.color(:red).bright +
        "'.".color(:red)
      end


      def redundant_constraint_message(actual_value)
        "' should NOT have default value but actually has '".color(:red) +
        actual_value.to_s.color(:red).bright + "'.".color(:red)
      end


      def column_header_message(column_schema)
        "The column '".color(:red) + column_schema.column_name.to_s.color(:red).bright
      end
    end
  end
end
