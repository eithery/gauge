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


      def column_exists?(table_name, column_schema)
        table(table_name).any? { |item| item.first == column_schema.to_key }
      end


      def column(table_name, column_schema)
        table(table_name).select do |item|
          item.first == column_schema.to_key
        end.first.last
      end

private

      def table(table_name)
        self.schema(table_name.to_s)
      end
    end
  end
end
