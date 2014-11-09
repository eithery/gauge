# Eithery Lab., 2014.
# Class Gauge::Schema::MetadataRepo
# Represent a repository storing metadata describing database structure.
require 'gauge'

module Gauge
  module Schema
    class MetadataRepo
      def self.databases
        @@databases ||= {}
      end


      def self.metadata_home
        @@metadata_home ||= File.expand_path(File.dirname(__FILE__) + '../../../../db')
      end
    end
  end
end
