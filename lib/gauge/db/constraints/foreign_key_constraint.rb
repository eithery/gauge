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
      end
    end
  end
end
