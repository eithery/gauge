# Eithery Lab., 2014.
# Class Gauge::SQL::Builder
# Factory class used to build SQL queries.
require 'gauge'

module Gauge
  module SQL
    class Builder
      @sql_home = File.expand_path(File.dirname(__FILE__) + '/../../../sql/')


      def initialize
        @sql = []
      end


      def build_sql(command, schema)
        @sql.clear
        yield self
        @sql << 'go'
        sql = @sql.join("\n")
        save_sql schema.table, script_file(command, schema), sql
        sql
      end


      def alter_table(table_schema)
        @sql << "alter table [#{table_schema.sql_schema}].[#{table_schema.local_name}]"
      end


      def add_column(column_schema)
        @sql << "add [#{column_schema.column_name}] #{column_attributes(column_schema)};"
      end

  private

      def self.sql_home
        Dir.mkdir(@sql_home) unless File.exists? @sql_home
        @sql_home
      end


      def save_sql(table_schema, script_name, sql)
        File.open("#{table_home(table_schema)}/#{script_name}", 'w') { |f| f.puts sql }
      end


      def table_home(table_schema)
        database = create_folder "#{Builder.sql_home}/#{table_schema.database_schema.sql_name}"
        tables = create_folder "#{database}/tables"
        create_folder "#{tables}/#{table_schema.table_name}"
      end


      def create_folder(path)
        Dir.mkdir(path) unless File.exists? path
        path
      end


      def script_file(command, schema)
        "add_#{schema.column_name}_column.sql"
      end


      def column_attributes(column)
        attrs = "#{column_type(column)} #{nullability(column)}"
        attrs += default_value(column) unless column.default_value.nil?
        attrs
      end


      def column_type(column)
        type = [column.data_type.to_s]
        type << "(#{column.length})" if [:nvarchar, :nchar].include? column.data_type
        type << "(18,2)" if column.column_type == :money
        type.join
      end


      def nullability(column)
        column.allow_null? ? 'null' : 'not null'
      end


      def default_value(column)
        ""
      end
    end
  end
end
