# Eithery Lab., 2014.
# Class Gauge::Validators::DatabaseValidator
# Checks a database structure against the predefined schema.
require 'gauge'

module Gauge
  module Validators
    class DatabaseValidator < Validators::Base
      check_all(:data_tables) { |db_schema| db_schema.tables.values }

      def check(database_schema, dba)
        info "Inspecting '#{database_schema.database_name.to_s}' database ..."
        super(database_schema, dba)
        errors
      end
    end
  end
end
