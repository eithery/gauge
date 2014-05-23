require 'gauge'

module Gauge
  module Validators
    class DataTableValidator < ValidatorBase

      def check(table_schema)
        DB::Adapter.session(table_schema.database_name) { |dba| validate(table_schema, dba) }
      end


      def validate(table_schema, dba)
        unless missing_table? table_schema, dba
          log "Check [#{table_schema.table_name}] data table" do
            self.errors.clear
            table_schema.columns.each { |col| super(col, dba) }
            self.errors
          end
        end
      end


  protected

      def validators
        [DataColumnValidator.new]
      end

  private

      def missing_table?(table_schema, dba)
        mtv = MissingTableValidator.new
        mtv.validate table_schema, dba
        errors.concat(mtv.errors)
        mtv.errors.any?
      end
    end
  end
end
