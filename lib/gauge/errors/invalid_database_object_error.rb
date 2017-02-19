# Eithery Lab, 2017
# Class Gauge::Errors::InvalidDatabaseObjectError
# Invalid database object error.

require 'gauge'

module Gauge
  module Errors
    class InvalidDatabaseObjectError < StandardError
      def initialize(message="Invalid database object")
        super
      end
    end
  end
end
