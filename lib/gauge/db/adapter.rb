# Eithery Lab, 2017
# Class Gauge::DB::Adapter
# Database adapter providing interation with Sequel.

require 'gauge'

module Gauge
  module DB
    class Adapter
      class << self
        attr_accessor :database
      end

      @database = nil

      def self.session(schema)
        Sequel.tinytds(dataserver: Connection.server, database: schema.database_name,
          user: Connection.user, password: Connection.password) do |dba|
          dba.test_connection
          begin
            self.database = dba
            yield dba
          ensure
            self.database = nil
          end
        end
      end
    end
  end
end
