# Eithery Lab., 2017
# Class Gauge::DB::Connection
# Encapsulates a database connection info.

require 'gauge'

module Gauge
  module DB
    class Connection
      class << self
        attr_reader :server, :user, :password
      end


      def self.configure(options)
        @server = options[:server]
        @user = options[:user]
        @password = options[:password]
      end
    end
  end
end
