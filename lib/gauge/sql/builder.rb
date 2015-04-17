# Eithery Lab., 2015.
# Class Gauge::SQL::Builder
# Factory class used to build SQL queries.

require 'gauge'

module Gauge
  module SQL
    class Builder
      def initialize
        @mode = :alter_table
        @sql_home ||= File.expand_path(File.dirname(__FILE__) + '/../../../sql/')
        @columns_to_add = {}
        @columns_to_alter = {}
        @constraints_to_drop = {}
      end


      def cleanup dbo
        dbo.class == Gauge::Schema::DatabaseSchema ? delete_database_sql(dbo) : delete_data_table_sql(dbo)
      end


      def create_table(table)
        @mode = :create_table
      end


      def add_column(column)
        @columns_to_add[column.to_sym] = column
      end


      def alter_column(column)
        @columns_to_alter[column.to_sym] = column
      end


      def drop_constraint(constraint)
        @constraints_to_drop[constraint.to_sym] = constraint
      end


      def build_sql(table)
        sql = method("#{@mode}_sql").call(table)
        save sql, to: file_name_for(@mode, table) unless sql.blank?
      end

  private

      def create_table_clause(table)
        "create table [#{table.sql_schema}].[#{table.local_name}]"
      end


      def alter_table_clause(table)
        "alter table [#{table.sql_schema}].[#{table.local_name}]"
      end


      def add_column_clause(column)
        "add [#{column.column_name}] #{column.sql_attributes}#{default_value(column)};"
      end


      def alter_column_clause(column)
        "alter column [#{column.column_name}] #{column.sql_attributes};"
      end


      def sql_home
        Dir.mkdir(@sql_home) unless File.exists? @sql_home
        @sql_home
      end


      def save(sql, options)
        file_name = options[:to]
        File.open(file_name, 'a') { |f| f.puts sql }
        sql
      end


      def table_home(table)
        database = create_folder "#{sql_home}/#{table.database_schema.sql_name}"
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


      def delete_database_sql database
        database_path = "#{sql_home}/#{database.sql_name}"
        FileUtils.remove_dir database_path, force: true
      end


      def delete_data_table_sql table
        tables_path = "#{sql_home}/#{table.database_schema.sql_name}/tables"
        FileUtils.remove_file "#{tables_path}/create_#{table.to_sym}.sql", force: true
        FileUtils.remove_file "#{tables_path}/alter_#{table.to_sym}.sql", force: true
      end


      def create_table_sql(table)
        sql = []
        sql << "#{create_table_clause table}"
        sql << "("
        sql << ");"
        sql << "go\n"
        sql.join("\n")
      end


      def alter_table_sql(table)
        sql = []
        @constraints_to_drop.each do |key, constraint|
          sql << "#{alter_table_clause table}"
          sql << "drop constraint #{constraint.name};"
          sql << "go\n"
        end
        @columns_to_add.each do |key, col|
          sql << "#{alter_table_clause table}"
          sql << "#{add_column_clause col}"
          sql << "go\n"
        end
        @columns_to_alter.each do |key, col|
          sql << "#{alter_table_clause table}"
          sql << "#{alter_column_clause col}"
          sql << "go\n"
        end
        sql.join("\n")
      end
    end
  end
end
