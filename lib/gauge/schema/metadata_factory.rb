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
    end
  end
end
