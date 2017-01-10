# Eithery Lab., 2017
# Class Gauge::Schema::DatabaseSchema
# Defines a database.

require 'gauge'

module Gauge
  module Schema
    class DatabaseSchema
      class << self
        attr_accessor :current
      end

      attr_reader :path, :name

      def initialize(path)
        @path = path
        @name = path.split('/').last
      end


      def database_name
        name
      end


      def database_schema
        self
      end


      def object_type
        'Database'
      end


      def to_sym
        name.downcase.to_sym
      end


      def tables
        load_tables if @tables.nil?
        @tables
      end


      def views
        load_views if @views.nil?
        @views
      end


      def define_table(table_name, options={}, &block)
        table_schema = DataTableSchema.new(table_name, options, &block)
        tables[table_schema.to_sym] = table_schema
      end


      def define_view(view_name, options={}, &block)
      end


  private

      def load_tables
        @tables = {}
        load_schemas_for 'tables'
      end


      def load_views
        @views = {}
        load_schemas_for 'views'
      end


      def load_schemas_for(kind)
        begin
          DatabaseSchema.current = self
          Dir["#{path}/**/#{kind}/**/*.rb"].each { |f| require f }
        ensure
          DatabaseSchema.current = nil
        end
      end
    end
  end
end
