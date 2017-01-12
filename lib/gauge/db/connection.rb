# Eithery Lab, 2017
# Class Gauge::DB::Connection
# A database connection info.

require 'gauge'

module Gauge
  module DB
    class Connection
      class << self
        attr_reader :server, :user, :password
      end


      def self.configure(server:, user:, password: nil)
        @server = server
        @user = user
        @password = password
      end
    end
  end
end
