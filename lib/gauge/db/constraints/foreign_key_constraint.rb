# Eithery Lab, 2017
# Class Gauge::DB::Constraints::ForeignKeyConstraint
# A foreign key constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class ForeignKeyConstraint < CompositeConstraint
        attr_reader :ref_table, :ref_columns

        def initialize(name, table:, columns:, ref_table:, ref_columns:)
          super(name, table: table, columns: columns)
          @ref_table = dbo_id(ref_table)
          @ref_columns = flatten_array_of ref_columns
        end


        def ==(other_key)
          return false if other_key.nil?
          table == other_key.table && columns.sort == other_key.columns.sort &&
          ref_table == other_key.ref_table && ref_columns.sort == other_key.ref_columns.sort
        end


        def ref_table_sql
          "#{ref_table_sql_schema}.#{ref_table_local_name}"
        end


  private

        def ref_table_sql_schema
          ref_table_name_parts.first
        end


        def ref_table_local_name
          ref_table_name_parts.drop(1).join('_')
        end


        def ref_table_name_parts
          ref_table.to_s.split('_')
        end
      end
    end
  end
end
