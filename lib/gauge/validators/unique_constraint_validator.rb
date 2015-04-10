# Eithery Lab., 2015.
# Class Gauge::Validators::UniqueConstraintValidator
# Checks unique constraints on the data table.

require 'gauge'

module Gauge
  module Validators
    class UniqueConstraintValidator < Validators::Base

      validate do |table_schema, table|
        table_schema.unique_constraints.each do |uc|
        end
      end
    end
  end
end
