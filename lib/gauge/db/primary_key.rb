# Eithery Lab., 2015.
# Class Gauge::DB::PrimaryKey
# Represents the actual primary key constraint.

require 'gauge'

module Gauge
  module DB
    class PrimaryKey
      attr_reader :name, :table, :columns

      def initialize(name, table, columns, options={})
        @name = name
        @table = table
        @columns = columns
        @clustered = clustered
      end


      def columns
        @columns ||= []
      end


      def clustered?
        @clustered
      end


      def composite?
        columns.length > 1
      end
    end
  end
end
