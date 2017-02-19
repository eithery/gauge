# Eithery Lab, 2017
# Class Gauge::Errors::InvalidMetadataError
# Invalid database object metadata error.

require 'gauge'

module Gauge
  module Errors
    class InvalidMetadataError < StandardError
      def initialize(message='Invalid metadata')
        super
      end
    end
  end
end
