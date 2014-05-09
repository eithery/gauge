require 'gauge'

module Gauge
  module Validators
    class DatabaseValidator
      include ConsoleListener

      def check(database_schema)
        info "Inspecting #{database_schema.database_name} database ..."
        database_schema.tables.values.each { |table| TableValidator.new.check(table) }
      end
    end
  end
end
