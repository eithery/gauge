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
        @unique = @clustered || options[:unique] == true
      end


      def clustered?
        @clustered
      end


      def unique?
        @unique
      end
    end
  end
end
