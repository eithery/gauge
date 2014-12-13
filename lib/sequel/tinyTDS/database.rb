# Eithery Lab., 2014.
# Class Sequel::TynyTDS::Database
# Extends Sequel Database functionality.
require 'sequel'
require 'gauge'

module Sequel
  module TinyTDS
    class Database < Sequel::Database

      def table_exists?(table_schema)
        self.tables(schema: table_schema.sql_schema).include?(table_schema.local_name.downcase.to_sym)
      end


      def column_exists?(column_schema)
        table(column_schema).any? { |item| item.first == column_schema.to_key }
      end


      def column(column_schema)
        column = table(column_schema).select do |item|
          item.first == column_schema.to_key
        end.first.last
        Gauge::DB::DataColumn.new(column)
      end


      def check_constraints(table_schema)
        []
      end


      def default_constraint(column_schema)
        ""
      end

private

      def table(column_schema)
        self.schema(column_schema.table.local_name)
      end
    end
  end
end
