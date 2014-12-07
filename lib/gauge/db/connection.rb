# Eithery Lab., 2014.
# Class Gauge::DB::Connection
# Encapsulates a database connection info.
require 'gauge'

module Gauge
  module DB
    class Connection
      class << self
        attr_accessor :server, :user, :password
      end


      def self.configure(options)
        self.server = options[:server]
        self.user = options[:user]
        self.password = options[:password]
      end
    end
  end
end
