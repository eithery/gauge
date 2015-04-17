# Eithery Lab., 2015.
# Class Gauge::Validators::MissingTableValidator
# Performs check for missing data table.

require 'gauge'

module Gauge
  module Validators
    class MissingTableValidator < Validators::Base

      validate do |table_schema, database, sql|
        result = true
        unless database.table_exists? table_schema.to_sym
          missing_table table_schema.table_name
          result = false
          sql.create_table table_schema
        end
        result
      end

  private

      def missing_table(table_name)
        errors << "Data table '<b>#{table_name}</b>' does not exist."
      end
    end
  end
end
