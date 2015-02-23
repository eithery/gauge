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


      def check_constraints
        sql = "select cc.constraint_name, col.table_catalog as database, col.table_schema, col.table_name, col.column_name, cc.check_clause " +
          "from information_schema.check_constraints as cc " +
          "inner join information_schema.constraint_column_usage col on cc.constraint_name = col.constraint_name;"

        self.[](sql).all.map do |row|
          Gauge::DB::Constraints::CheckConstraint.new(row[:constraint_name], table_key(row), column_key(row), row[:check_clause])
        end
      end


      def default_constraints
        sql = "select dc.name as constraint_name, s.name as table_schema, t.name as table_name, col.name as column_name, dc.definition " +
          "from sys.default_constraints as dc " +
          "inner join sys.columns as col on col.object_id = dc.parent_object_id and col.column_id = dc.parent_column_id " +
          "inner join sys.tables as t on t.object_id = col.object_id " +
          "inner join sys.schemas as s on s.schema_id = t.schema_id;"

        self.[](sql).all.map do |row|
          Gauge::DB::Constraints::DefaultConstraint.new(row[:constraint_name], table_key(row), column_key(row), row[:definition])
        end
      end

private

      def table(column_schema)
        self.schema(column_schema.table.local_name)
      end


      def table_key(dataset_row)
        "#{dataset_row[:table_schema]}_#{dataset_row[:table_name]}".downcase.to_sym
      end


      def column_key(dataset_row)
        dataset_row[:column_name].downcase.to_sym
      end
    end
  end
end
