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
        @@metadata_home ||= expand_path('/db')
      end


      def self.load
        require expand_path('/config/databases.rb')
      end

private

      def self.expand_path(path)
        File.expand_path(File.dirname(__FILE__) + '/../../../' + path)
      end
    end
  end
end
