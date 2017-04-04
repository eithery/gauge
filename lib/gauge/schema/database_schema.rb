# Eithery Lab, 2017
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


      def table_schema(table_name)
        tables[table_name.to_s.downcase.to_sym] || tables[Gauge::Helpers::NameParser.dbo_key_of table_name]
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


      def has_table?(table_name)
        !table_schema(table_name).nil?
      end


      def has_view?(view_name)
        view_key = Gauge::Helpers::NameParser.dbo_key_of view_name
        views.include?(view_key)
      end


      def define_table(table_name, options={}, &block)
        options[:db] = to_sym
        table_schema = DataTableSchema.new(table_name, options, &block)
        tables[table_schema.to_sym] = table_schema
      end


      def define_view(view_name, options={}, &block)
      end


      def cleanup_sql_files
        database_path = "#{ApplicationHelper.sql_home}/#{name}"
        FileUtils.remove_dir(database_path, force: true)
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
          Dir["#{path}/**/#{kind}/**/*.rb"].each { |f| load f }
        ensure
          DatabaseSchema.current = nil
        end
      end
    end
  end
end
