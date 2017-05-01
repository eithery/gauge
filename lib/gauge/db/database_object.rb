# Eithery Lab, 2017
# Class Gauge::DB::DatabaseObject
# A base class for all database objects.

module Gauge
  module DB
    class DatabaseObject
      attr_reader :name

      def initialize(name:)
        @name = name.to_s
      end


      def db_object_id
        name.downcase.gsub(/\./, '_').to_sym
      end

      alias_method :to_sym, :db_object_id
    end
  end
end
