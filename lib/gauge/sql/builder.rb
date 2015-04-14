# Eithery Lab., 2015.
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
        sql = @sql.join("\n") + "\n"
        save sql, to: file_name_for(command, schema)
        sql
      end


      def alter_table(table)
        @sql << "alter table [#{table.sql_schema}].[#{table.local_name}]"
      end


      def add_column(column)
        @sql << "add [#{column.column_name}] #{column.sql_attributes}#{default_value(column)};"
      end


      def alter_column(column)
        @sql << "alter column [#{column.column_name}] #{column.sql_attributes};"
      end

  private

      def self.sql_home
        Dir.mkdir(@sql_home) unless File.exists? @sql_home
        @sql_home
      end


      def save(sql, options)
        file_name = options[:to]
        File.open(file_name, 'a') { |f| f.puts sql }
      end


      def table_home(table)
        database = create_folder "#{Builder.sql_home}/#{table.database_schema.sql_name}"
        tables = create_folder "#{database}/tables"
      end


      def create_folder(path)
        Dir.mkdir(path) unless File.exists? path
        path
      end


      def file_name_for(command, schema)
        "#{table_home(schema.table_schema)}/#{prefix(command)}_#{schema.table_schema.to_sym}.sql"
      end


      def prefix(command)
        command == :create_table ? 'create' : 'alter'
      end


      def default_value(column)
        " default #{column.sql_default_value}" unless column.sql_default_value.nil?
      end
    end
  end
end
