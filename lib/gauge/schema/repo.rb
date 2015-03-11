# Eithery Lab., 2014.
# Class Gauge::Schema::Repo
# Represent a repository containing metadata describing database structure.
require 'gauge'

module Gauge
  module Schema
    class Repo
      class << self
        attr_accessor :databases, :current_db_schema
        private :current_db_schema
      end

      @databases = {}


      def self.load
        require expand_path('/config/databases.rb')
        databases.values.each do |db_schema|
          with_database db_schema do
            Dir["#{home_for(db_schema)}/**/#{db_schema.database_name}/**/tables/**/*.rb"].each { |f| require f }
          end
        end
      end


      def self.define_database(*args, &block)
        db_schema = DatabaseSchema.new(*args, &block)
        databases[db_schema.to_key] = db_schema
      end


      def self.define_table(table_name, options={}, &block)
        options[:database] = current_db_schema
        table_schema = DataTableSchema.new(table_name, options, &block)
        current_db_schema.tables[table_schema.to_key] = table_schema
      end


      def self.clear
        databases.clear
      end


      def self.database?(dbo_name)
        databases.include?(dbo_name.downcase.to_sym) ||
          databases.values.any? { |db_schema| dbo_name.downcase == db_schema.sql_name.downcase }
      end


      def self.table?(dbo_name)
        databases.values.each do |db_schema|
          return true if db_schema.tables.include?(table_key dbo_name)
        end
        false
      end


      def self.schema(dbo_name)
        return database_schema dbo_name if database? dbo_name
        table_schema dbo_name if table? dbo_name
      end

private

      def self.expand_path(path)
        File.expand_path(File.dirname(__FILE__) + '/../../../' + path)
      end


      def self.table_key(dbo_name)
        Gauge::Helpers::NameParser.dbo_key_of dbo_name
      end


      def self.database_schema(dbo_name)
        databases[dbo_name.downcase.to_sym] ||
          databases.values.select { |db_schema| dbo_name.downcase == db_schema.sql_name.downcase }.first
      end


      def self.table_schema(dbo_name)
        databases.values.each do |db_schema|
          table_schema = db_schema.tables[table_key dbo_name]
          return table_schema unless table_schema.nil?
        end
        nil
      end


      def self.with_database(db_schema)
        begin
          @current_db_schema = db_schema
          yield
        ensure
          @current_db_schema = nil;
        end
      end


      def self.home_for(db_schema)
        db_schema.home.nil? ? expand_path('db') : db_schema.home
      end
    end
  end
end
