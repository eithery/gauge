require 'sequel'
require 'gauge'

module Sequel
  module TinyTDS
    class Database < Sequel::Database
      def table_exists?(table_schema)
        self.tables(schema: table_schema.sql_schema).include?(table_schema.to_key)
      end


      def column_exists?(column_schema)
        self.schema(column_schema.table_name).any? { |item| item.first == column_schema.to_key }
      end


      def data_column(column_schema)
        self.schema(column_schema.table_name).select do |item|
          item.first == column_schema.to_key
        end.first.last
      end
    end
  end
end
