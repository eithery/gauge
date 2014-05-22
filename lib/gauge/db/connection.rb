require 'gauge'

module Gauge
  module DB
    class Connection
      def self.configure(options)
        @@server = options[:server]
        @@user = options[:user]
        @@password = options[:password]
      end


      def self.server
        @@server
      end


      def self.user
        @@user
      end


      def self.password
        @@password
      end
    end
  end
end
