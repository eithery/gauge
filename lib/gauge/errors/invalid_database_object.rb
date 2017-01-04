# Eithery Lab., 2017
# Class Gauge::Errors::InvalidDatabaseObject
# Invalid database object error.

require 'gauge'

module Gauge
  module Errors
    class InvalidDatabaseObject < StandardError
      def initialize(message="Invalid database object")
        super
      end
    end
  end
end
