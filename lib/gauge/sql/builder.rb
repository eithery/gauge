# Eithery Lab., 2014.
# Class Gauge::SQL::Builder
# Factory class used to build SQL queries.
require 'gauge'

module Gauge
  module SQL
    class Builder
      @sql_home = File.expand_path(File.dirname(__FILE__) + '/../../../sql/')


      def self.save_sql(table_schema, script_name, sql)
        File.open("#{table_home(table_schema)}/#{script_name}.sql", 'w') { |f| f.puts sql }
      end

  private

      def self.sql_home
        Dir.mkdir(@sql_home) unless File.exists? @sql_home
        @sql_home
      end


      def self.table_home(table_schema)
        tables_root = "#{sql_home}/tables"
        Dir.mkdir(tables_root) unless File.exists? tables_root
        table_folder = "#{tables_root}/#{table_schema.table_name}"
        Dir.mkdir(table_folder) unless File.exists? table_folder
        table_folder
      end
    end
  end
end
