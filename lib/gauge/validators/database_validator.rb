# Eithery Lab., 2014.
# Class Gauge::Validators::DatabaseValidator
# Checks a database structure against the predefined schema.
require 'gauge'

module Gauge
  module Validators
    class DatabaseValidator < Validators::Base
      check_all(:data_tables) { |db_schema| db_schema.tables.values }


      def check(schema, dba)
        return super(schema, dba) unless schema.tables.empty?

        errors << "Cannot found data tables metadata for '<b>#{schema.sql_name}</b>' database."
        error errors.first
      end
    end
  end
end
