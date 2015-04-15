# Eithery Lab., 2015.
# Class Gauge::SQL::Provider
# Provides infrastructure to build SQL statements.

require 'gauge'

module Gauge
  module SQL
    class Provider
      attr_reader :sql

      def build_sql(*args, &block)
        builder = SQL::Builder.new
        @sql = builder.build_sql(*args, &block)
      end


      def build_alter_column_sql(column_schema)
        build_sql(:alter_column, column_schema) do |sql|
          sql.alter_table column_schema.table
          sql.alter_column column_schema
        end
      end


      def cleanup dbo
        dbo.class == Gauge::Schema::DatabaseSchema ? delete_database_sql(dbo) : delete_data_table_sql(dbo)
      end

  private

      def delete_database_sql database
        database_path = "#{Builder.sql_home}/#{database.sql_name}"
        FileUtils.remove_dir database_path, force: true
      end


      def delete_data_table_sql table
        tables_path = "#{Builder.sql_home}/#{table.database_schema.sql_name}/tables"
        FileUtils.remove_file "#{tables_path}/create_#{table.to_sym}.sql", force: true
        FileUtils.remove_file "#{tables_path}/alter_#{table.to_sym}.sql", force: true
      end
    end
  end
end
