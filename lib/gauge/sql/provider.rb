# Eithery Lab., 2014.
# Module Gauge::SQL::Provider
# Used as mix-in module providing access to SQL build infrastructure.
require 'gauge'

module Gauge
  module SQL
    module Provider
      attr_reader :sql

      def build_sql(*args, &block)
        builder = SQL::Builder.new
        @sql = builder.build_sql(*args, &block)
      end


      def build_alter_column_sql(column_schema)
        build_sql(:alter_column, column_schema) do |sql|
          sql.drop_check_constraints column_schema.table
          sql.drop_default_constraint column_schema

          sql.alter_table column_schema.table
          sql.alter_column column_schema

          sql.add_default_constraint column_schema
          sql.add_check_constraints column_schema.table
        end
      end
    end
  end
end