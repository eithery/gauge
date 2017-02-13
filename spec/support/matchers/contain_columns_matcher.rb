# Eithery Lab, 2017
# Gauge::SchemaMatchers::ContainColumnsMatcher
# Verifies that a data table definition contains the specified columns.

require 'gauge'

module Gauge
  module SchemaMatchers
    class ContainColumnsMatcher

      def initialize(*columns)
        @columns = [columns].flatten.map { |col| col.downcase.to_sym }
      end


      def matches?(table_schema)
        @columns.all? do |column|
          table_schema.columns.any? { |col| col.column_name.downcase.to_sym == column }
        end
      end


      def description
        "Data table definition contains #{@columns.inspect} columns"
      end


      def failure_message
        "Data table definition does not contain one or more columns from #{@columns.inspect}"
      end


      def failure_message_when_negated
        "Data table definition contains one or mode columns from #{@columns.inspect}"
      end
    end


    def contain_columns(*columns)
      ContainColumnsMatcher.new(columns)
    end
  end
end
