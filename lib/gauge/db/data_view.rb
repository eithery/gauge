# Eithery Lab., 2015.
# Class Gauge::DB::DataView
# Represents the actual data view in DB.

require 'gauge'

module Gauge
  module DB
    class DataView < DatabaseObject
      attr_reader :sql

      def initialize(name, sql, options={})
        super name
        @sql = sql
        @options = options
      end


      def indexed?
        @options[:indexed] == true
      end


      def with_schemabinding?
      end


      def indexes
      end


      def base_tables
      end


      def to_sym
        Gauge::Helpers::NameParser.dbo_key_of name
      end
    end
  end
end
