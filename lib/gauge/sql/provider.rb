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
    end
  end
end
