# Eithery Lab, 2017
# Gauge::SchemaMatchers::BeConvertedToMatcher
# Verifies conversion data column types to SQL data types. 

require 'gauge'

module Gauge
  module SchemaMatchers
    class BeConvertedToMatcher

      def initialize(sql_type)
        @sql_type = sql_type
      end


      def matches?(column_types)
        @column_types = [column_types].flatten
        columns = @column_types.map do |t|
          Schema::DataColumnSchema.new(name: 'sample_column_name', type: t)
        end
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
