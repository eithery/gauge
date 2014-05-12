require 'gauge'

module Gauge
  module Validators
    class DatabaseValidator
      include ConsoleListener

      def initialize(connection)
        @connection = connection
      end


      def check(database_schema)
        info "Inspecting #{database_schema.database_name} database ..."
        errors = []
        Sequel.tinytds(dataserver: @connection.server, database: database_schema.database_name,
          user: @connection.user, password: @connection.password) do |dba|

          dba.test_connection
          database_schema.tables.values.each do |table|
            TableValidator.new(dba).check(table)
          end
        end
      end
    end
  end
end
