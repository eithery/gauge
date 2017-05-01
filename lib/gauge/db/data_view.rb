# Eithery Lab, 2017
# Class Gauge::DB::DataView
# An actual database view.

require 'gauge'

module Gauge
  module DB
    class DataView < DatabaseObject
      attr_reader :sql

      def initialize(name, sql:, indexed: false)
        super name
        @sql = sql
        @indexed = indexed
      end


      def indexed?
        @indexed == true
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
