# Eithery Lab, 2017
# Class Gauge::Validators::DatabaseValidator
# Checks a database structure against a predefined schema.

require 'gauge'

module Gauge
  module Validators
    class DatabaseValidator < Validators::Base
      check_all :data_tables, with_schema: ->db { db.tables.values }
      check_all :data_views, with_schema: ->db { db.views.values }


      def check(database_schema, database)
        SQL::Builder.new.cleanup database_schema
        return super unless database_schema.tables.empty?

        errors << "Cannot found data tables metadata for '<b>#{database_schema.sql_name}</b>' database."
        error errors.first
      end
    end
  end
end
