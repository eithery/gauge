require 'gauge'

module Gauge
  module Validators
    class DataTableValidator < ValidatorBase

      def check(table_schema)
        DB::Adapter.session(table_schema.database_name) { |dba| validate(table_schema, dba) }
      end


      def validate(table_schema, dba)
        super(table_schema, dba) do
          log "Check [#{table_schema.table_name}] data table" do
            self.errors.clear
            table_schema.columns.each { |col| super(col, dba) }
            self.errors
          end
        end
      end


  protected

      def before_validators
        [MissingTableValidator.new]
      end


      def validators
        [DataColumnValidator.new]
      end
    end
  end
end
