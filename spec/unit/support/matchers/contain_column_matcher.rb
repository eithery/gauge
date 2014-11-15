# Eithery Lab., 2014.
# Gauge::SchemaMatchers::ContainColumnMatcher.
# Custom RSpec matcher verifying that data table definition contains the specified column.
require 'gauge'

module Gauge
  module SchemaMatchers
    class ContainColumnMatcher
      def initialize(column_name)
        @column_name = column_name
      end


      def matches?(table_schema)
        table_schema.columns.any? { |col| col.column_name.downcase.to_sym == @column_name.downcase.to_sym }
      end


      def description
        "Data table definition contains '#{@column_name}' columns"
      end


      def failure_message
        "Data table definition does not contain '#{@column_name}' column but should"
      end


      def failure_message_when_negated
        "Data table definition contains '#{@column_name}' columns but should not"
      end
    end


    def contain_column(column_name)
      ContainColumnMatcher.new(column_name)
    end
  end
end
