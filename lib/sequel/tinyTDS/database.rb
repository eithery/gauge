# Eithery Lab., 2014.
# Class Sequel::TynyTDS::Database
# Extends Sequel Database functionality.
require 'sequel'
require 'gauge'

module Sequel
  module TinyTDS
    class Database < Sequel::Database

      # Determines whether the specified data table exists in the database.
      def table_exists?(table_schema)
        self.tables(schema: table_schema.sql_schema).include?(table_schema.local_name.downcase.to_sym)
      end


      # Determines whether the specified data column exists in the data table.
      def column_exists?(column_schema)
        self.schema(column_schema.table_name).any? { |item| item.first == column_schema.to_key }
      end


      # Returns the actual SQL metadata for the data column
      def data_column(column_schema)
        self.schema(column_schema.table_name).select do |item|
          item.first == column_schema.to_key
        end.first.last
      end
    end
  end
end
