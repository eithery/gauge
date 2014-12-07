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
        :constraint_mismatch unless matched? expected_default, actual_default
      end


      def matched?(expected_default, actual_default)
        return actual_default.to_s =~ uid_pattern if expected_default == Schema::DataColumnSchema::UID
        actual_default == expected_default
      end


      def column_default(column_schema, db_column)
        default_value = actual_default_value(db_column)
        column_schema.bool? ? convert_to_bool(default_value) : default_value
      end


      def convert_to_bool(column_default_value)
        case column_default_value
          when 0 then false
          when 1 then true
        end
      end


      def actual_default_value(db_column)
        default_value = db_column[:ruby_default].nil? ? db_column[:default] : db_column[:ruby_default]
        return sequel_constant(default_value) if default_value.kind_of? Sequel::SQL::Constant
        return $1 if default_value.to_s =~ /\A\((.*)\)\z/i
        default_value
      end


      def sequel_constant(default_value)
        value = default_value.constant
        value == :CURRENT_TIMESTAMP ? 'getdate()' : value
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
