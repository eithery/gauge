# Eithery Lab., 2014.
# Class Gauge::DB::Adapter
# Database adapter class encapsulating interations with Sequel.
require 'gauge'

module Gauge
  module DB
    class Adapter
      def self.session(database_name)
        Sequel.tinytds(dataserver: Connection.server, database: database_name, user: Connection.user,
          password: Connection.password) do |dba|
          dba.test_connection
          yield dba
        end
      end
    end
  end
end
