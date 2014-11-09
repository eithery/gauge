# Eithery Lab., 2014.
# Class Gauge::Validators::DatabaseValidator
# Checks a database structure against the predefined schema.
require 'gauge'

module Gauge
  module Validators
    class DatabaseValidator < ValidatorBase

      # Performs validation check.
      def check(database_schema)
        info "Inspecting '#{database_schema.database_name.to_s}' database ..."
        DB::Adapter.session(database_schema.sql_name) do |dba|
          database_schema.tables.values.each { |table| validate table, dba }
        end
      end

protected

      # Child validators.
      def validators
        [DataTableValidator.new]
      end
    end
  end
end
