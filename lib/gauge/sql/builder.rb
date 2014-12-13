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


      def alter_table(table)
        @sql << "alter table [#{table.sql_schema}].[#{table.local_name}]"
      end


      def add_column(column)
        @sql << "add [#{column.column_name}] #{column.sql_attributes}#{default_value(column)};"
      end


      def alter_column(column)
        @sql << "alter column [#{column.column_name}] #{column.sql_attributes};"
      end


      def drop_check_constraints(table)
#        DB::Adapter.database.check_constraints(table).each do |cc|
#          alter_table table
#          @sql << "drop constraint #{cc};\n"
#        end
      end


      def add_check_constraints(table)
      end


      def drop_default_constraint(column)
      end


      def add_default_constraint(column)
      end

  private

      def self.sql_home
        Dir.mkdir(@sql_home) unless File.exists? @sql_home
        @sql_home
      end


      def save_sql(table, script_name, sql)
        File.open("#{table_home(table)}/#{script_name}", 'w') { |f| f.puts sql }
      end


      def table_home(table)
        database = create_folder "#{Builder.sql_home}/#{table.database_schema.sql_name}"
        tables = create_folder "#{database}/tables"
        create_folder "#{tables}/#{table.table_name}"
      end


      def create_folder(path)
        Dir.mkdir(path) unless File.exists? path
        path
      end


      def script_file(command, schema)
        "#{prefix(command)}_#{schema.column_name}_column.sql"
      end


      def prefix(command)
        case command
          when :add_column then 'add'
          when :alter_column then 'alter'
        end
      end


      def default_value(column)
        " default #{column.sql_default_value}" unless column.sql_default_value.nil?
      end
    end
  end
end
