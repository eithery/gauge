# Eithery Lab, 2017
# Class Gauge::Schema::DatabaseSchema
# Defines a database.

require 'gauge'

module Gauge
  module Schema
    class DatabaseSchema
      include Gauge::Helpers
      include Gauge::Helpers::NamesHelper

      attr_reader :path, :name
      alias_method :database_name, :name


      def initialize(path)
        @path = path
        @name = path.split('/').last
      end


      def database_id
        name.downcase.to_sym
      end

      alias_method :to_sym, :database_id


      def table_schema(table_name)
        tables[table_name.to_s.downcase.to_sym] || tables[dbo_id(table_name)]
      end


      def object_type
        'Database'
      end


      def tables
        if @tables.nil?
          @tables = {}
          load_schemas_for :tables
        end
        @tables
      end


      def views
        if @views.nil?
          @views = {}
          load_schemas_for :views
        end
        @views
      end


      def has_table?(table_name)
        !table_schema(table_name).nil?
      end


      def has_view?(view_name)
        view_id = NameParser.dbo_key_of view_name
        views.include?(view_id)
      end


      def table(table_name, sql_schema: nil, table_type: nil, &block)
        table_schema = DataTableSchema.new(name: table_name, sql_schema: sql_schema, db: database_id,
          table_type: table_type, &block)
        tables[table_schema.table_id] = table_schema
      end


      def view(view_name, sql_schema: nil, &block)
      end


      def cleanup_sql_files
        database_path = "#{ApplicationHelper.sql_home}/#{name}"
        FileUtils.remove_dir(database_path, force: true)
      end


  private

      def load_schemas_for(kind)
        Dir["#{path}/**/#{kind.to_s}/**/*.rb"].each { |f| instance_eval(File.read(f)) }
      end
    end
  end
end
