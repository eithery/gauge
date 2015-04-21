# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::ForeignKeyConstraint
# Represents the foreign key constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class ForeignKeyConstraint < CompositeConstraint
        attr_reader :ref_table, :ref_columns

        def initialize(name, table, columns, ref_table, ref_columns)
          super(name, table, columns)
          @ref_table = Gauge::Helpers::NameParser.dbo_key_of ref_table
          @ref_columns = flatten_array_of ref_columns
        end


        def ==(other_key)
          return false if other_key.nil?
          table == other_key.table && columns.sort == other_key.columns.sort &&
          ref_table == other_key.ref_table && ref_columns.sort == other_key.ref_columns.sort
        end
      end
    end
  end
end
