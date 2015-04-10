# Eithery Lab., 2015.
# Class Gauge::DB::Index
# Represents the database index on the data table or data view.

require 'gauge'

module Gauge
  module DB
    class Index < Constraints::CompositeConstraint

      def initialize(name, table, columns, options={})
        super(name, table, columns)
        @clustered = options[:clustered] == true
        @unique = options[:unique] == true
      end


      def clustered?
        @clustered
      end


      def unique?
        @unique || clustered?
      end


      def ==(other_index)
        return false if other_index.nil?

        table == other_index.table &&
        columns.sort == other_index.columns.sort &&
        clustered? == other_index.clustered? &&
        unique? == other_index.unique?
      end
    end
  end
end
