# Eithery Lab., 2014.
# Class Gauge::Schema::MetadataRepo
# Represent a repository storing metadata describing database structure.
require 'gauge'

module Gauge
  module Schema
    class MetadataRepo
      def self.databases
        @@databases ||= {}
      end


      def self.metadata_home
        @@metadata_home ||= expand_path('/db')
      end


      def self.load
        require expand_path('/config/databases.rb')
      end


      def self.clear
        databases.clear
      end


      def self.database?(dbo)
        databases.include?(dbo.to_sym) || databases.values.any? { |db_schema| dbo == db_schema.sql_name }
      end


      def self.table?(dbo)
        databases.values.each do |db_schema|
          return true if db_schema.tables.include?(dbo.to_sym)
        end
        false
      end
#      table_template(dbo_name).any? || table_template(dbo_name.underscore).any? ||
#        table_template(dbo_name.split('.').last).any?



private

      def self.expand_path(path)
        File.expand_path(File.dirname(__FILE__) + '/../../../' + path)
      end
    end
  end
end
