require 'gauge'

module Gauge
  module Validators
    class DatabaseValidator
      include ConsoleListener

      def initialize(db_adapter)
        @dba = db_adapter
      end


      def check(database_schema)
        info "Inspecting #{database_schema.database_name} database ..."

        database_schema.tables.values.each do |table|
          TableValidator.new(@dba).check(table)
        end
      end
    end
  end
end
