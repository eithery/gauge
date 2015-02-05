# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::ForeignKeyConstraint
# Represents the foreign key constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class ForeignKeyConstraint < DatabaseConstraint
        attr_reader :ref_table, :ref_columns

        def initialize(name, table, columns, ref_table, ref_columns)
          super(name, table, columns)
          @ref_table = ref_table.to_s.gsub('.', '_').downcase.to_sym
          @ref_columns = [ref_columns].flatten.map { |col| col.downcase.to_sym }
        end
      end
    end
  end
end
