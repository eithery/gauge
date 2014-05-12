require 'gauge'

module Gauge
  module DB
    class Connection
      attr_reader :server, :user, :password

      def initialize(global_options)
        @server = global_options[:server]
        @user = global_options[:user]
        @password = global_options[:password]
      end
    end
  end
end
