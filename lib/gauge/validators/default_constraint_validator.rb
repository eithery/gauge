# Eithery Lab., 2014.
# Class Gauge::Validators::DefaultConstraintValidator
# Checks default constraints for data columns.
require 'gauge'

module Gauge
  module Validators
    class DefaultConstraintValidator < Validators::Base
      validate do |column_schema, db_column|
      end

  private

      def missing_constraint_message(column_schema, expected_value)
        "- missing default value '".color(:red) + expected_value.to_s.color(:red).bright + "'.".color(:red)
      end


      def constraint_mismatch_message(column_schema, expected_value, actual_value)
        "should have '".color(:red) + expected_value.to_s.color(:red).bright +
        "' default value but actually has '".color(:red) + actual_value.to_s.color(:red).bright +
        "'.".color(:red)
      end


      def redundant_constraint_message(actual_value)
        "should NOT have default value but actually has '".color(:red) +
        actual_value.to_s.color(:red).bright + "'.".color(:red)
      end


      def column_header_message(column_schema)
        "The column '".color(:red) + column_schema.column_name.to_s.color(:red).bright + "' ".color(:red)
      end
    end
  end
end
