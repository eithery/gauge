# Eithery Lab., 2015.
# Class Gauge::Validators::PrimaryKeyValidator
# Checks primary key constraint on the table.

require 'gauge'

module Gauge
  module Validators
    class PrimaryKeyValidator < Validators::Base

      validate do |table_schema, table|
        case mismatch(table_schema.primary_key, table.primary_key)
          when :missing_primary_key
            errors << "Missing primary key"
          when :primary_key_mismatch
            errors << "Primary keys mismatch"
        end
      end

  private

      def mismatch(expected_key, actual_key)
        return :missing_primary_key if actual_key.nil?
        :primary_key_mismatch if expected_key != actual_key
      end
    end
  end
end
