# Eithery Lab, 2017
# Class Gauge::DB::DatabaseObject
# A base class for all database objects.

module Gauge
  module DB
    class DatabaseObject
      attr_reader :name

      def initialize(object_name)
        @name = object_name.to_s
      end


      def to_sym
        name.downcase.gsub(/\./, '_').to_sym
      end
    end
  end
end
