# Eithery Lab., 2015.
# Class Gauge::Validators::ForeignKeyValidator
# Checks foreign key constraints on the table.

require 'gauge'

module Gauge
  module Validators
    class ForeignKeyValidator < Validators::Base

      validate do |table_schema, table, sql|
      end
    end
  end
end
