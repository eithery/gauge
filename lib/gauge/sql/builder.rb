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
        database = create_folder "#{sql_home}/#{table_schema.database_schema.sql_name}"
        tables = create_folder "#{database}/tables"
        create_folder "#{tables}/#{table_schema.table_name}"
      end


      def self.create_folder(path)
        Dir.mkdir(path) unless File.exists? path
        path
      end
    end
  end
end
