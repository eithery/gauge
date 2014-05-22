require 'gauge'

module Gauge
  module Validators
    class DatabaseValidator < ValidatorBase
      def check(database_schema)
        info "Inspecting #{database_schema.database_name} database ..."

        DB::Adapter.session(database_schema.database_name) do |dba|
          database_schema.tables.values.each { |table| validate table, dba }
        end
      end

protected

      def validators
        [DataTableValidator.new]
      end
    end
  end
end
