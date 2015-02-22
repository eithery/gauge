# Eithery Lab., 2015.
# Class Gauge::DB::DatabaseObject
# Represents the base class for all database objects.

module Gauge
  module DB
    class DatabaseObject
      attr_reader :name


      def initialize(object_name)
        @name = object_name.downcase
      end
    end
  end
end
