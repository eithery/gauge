# Eithery Lab., 2017
# Class Gauge::Schema::Repo
# A repository containing metadata for databases.

require 'gauge'

module Gauge
  module Schema
    class Repo
      include Gauge::Helpers

      def initialize(*paths)
        paths.each do |path|
          home = File.absolute_path(path, ApplicationHelper.root_path)
          Dir["#{home}/*/"].each do |db_path|
            db = DatabaseSchema.new(db_path)
            databases[db.to_sym] = db
          end
        end
      end


      def databases
        @databases ||= {}
      end


      def clear
        databases.clear
      end


      def database?(database_name)
        db_key = database_name.to_s.downcase.to_sym
        databases.include?(db_key)
      end


      def table?(dbo_name)
        databases.values.any? { |db| db.has_table? dbo_name }
      end


      def schema(dbo_name)
        databases[dbo_name.to_s.downcase.to_sym] || table_schema(dbo_name)
      end


      def validator_for(dbo)
        if database?(dbo)
          Validators::DatabaseValidator.new
        elsif table?(dbo)
          Validators::DataTableValidator.new
        else
          raise Errors::InvalidDatabaseObjectError, "Cannot determine a metadata type for '#{dbo}'"
        end
      end


private

      def table_schema(dbo_name)
        databases.values.each do |db_schema|
          table_schema = db_schema.table_schema(dbo_name)
          return table_schema unless table_schema.nil?
        end
        nil
      end
    end
  end
end
