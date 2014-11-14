# Eithery Lab., 2014.
# Class Gauge::Schema::MetadataFactory
# Provides factory methods to create database metadata objects.
require 'gauge'

module Gauge
  module Schema
    class MetadataFactory
      def self.define_database(database_name, options)
        Repo.databases[database_name] = DatabaseSchema.new(database_name, options)
      end


      def self.define_table(*args)
        table_schema = DataTableSchema.new(*args)
        database_schema = Repo.databases[table_schema.database_name]
        database_schema.tables[table_schema.to_key] = table_schema
      end
    end
  end
end
