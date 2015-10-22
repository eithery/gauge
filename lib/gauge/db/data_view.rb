# Eithery Lab., 2015.
# Class Gauge::DB::DataView
# Represents the actual data view in DB.

require 'gauge'

module Gauge
  module DB
    class DataView < DatabaseObject
      def initialize(name)
        super
      end


      def indexed?
      end


      def with_schemabinding?
      end


      def indexes
      end


      def base_tables
      end


      def sql
      end


      def to_sym
        Gauge::Helpers::NameParser.dbo_key_of name
      end
    end
  end
end
