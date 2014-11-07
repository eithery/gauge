# Eithery Lab., 2014.
# Gauge::SchemaMatchers::BeConvertedToMatcher.
# Custom RSpec matcher verifying conversion Gauge data column types to SQL data types. 
require 'gauge'

module Gauge
  module SchemaMatchers
    class BeConvertedToMatcher
      def initialize(sql_type)
        @sql_type = sql_type
      end


      def matches?(column_types)
        @column_types = column_types
        columns = column_types.map { |t| Schema::DataColumnSchema.new('sample_table_name', type: t) }
        columns.all? { |col| col.data_type == @sql_type }
      end


      def description
        "conversion #{@column_types.inspect} to '#{@sql_type}' sql type"
      end


      def failure_message
        "one or more column types from #{@column_types.inspect} cannot be converted to '#{@sql_type}' sql type"
      end
    end


    def be_converted_to(sql_type)
      BeConvertedToMatcher.new(sql_type)
    end
  end
end
