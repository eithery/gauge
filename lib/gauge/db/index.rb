# Eithery Lab, 2017
# Class Gauge::DB::Index
# A database index defined on a data table or data view.

require 'gauge'

module Gauge
  module DB
    class Index < Constraints::CompositeConstraint

      def initialize(name:, table:, columns:, unique: false, clustered: false)
        super(name: name, table: table, columns: columns)
        @clustered = clustered
        @unique = unique
      end


      def clustered?
        @clustered == true
      end


      def unique?
        @unique == true || clustered?
      end


      def ==(other_index)
        super && clustered? == other_index.clustered? && unique? == other_index.unique?
      end
    end
  end
end
