require 'gauge'

module Gauge
  module Validators
    class TableValidator
      include ConsoleListener

      def check(table_schema)
        log "Inspecting #{table_schema.table_name} data table" do
          []
        end
#        database.validate_table table_spec
      end
    end
  end
end
