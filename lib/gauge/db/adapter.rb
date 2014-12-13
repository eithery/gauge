# Eithery Lab., 2014.
# Class Gauge::DB::Adapter
# Database adapter class encapsulating interations with Sequel.
require 'gauge'

module Gauge
  module DB
    class Adapter
      class << self
        attr_accessor :database
      end

      @database = nil

      def self.session(schema)
        Sequel.tinytds(dataserver: Connection.server, database: schema.database_schema.sql_name,
          user: Connection.user, password: Connection.password) do |dba|
          dba.test_connection

          self.database = dba
          yield dba
          self.database = nil
        end
      end
    end
  end
end
