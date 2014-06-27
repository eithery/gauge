# Eithery Lab., 2014.
# Class Gauge::DB::Connection
# Encapsulates a database connection info.
require 'gauge'

module Gauge
  module DB
    class Connection

      # Configures DB connection.
      def self.configure(options)
        @@server = options[:server]
        @@user = options[:user]
        @@password = options[:password]
      end


      # Server name.
      def self.server
        @@server
      end


      # User name.
      def self.user
        @@user
      end


      def self.password
        @@password
      end
    end
  end
end
