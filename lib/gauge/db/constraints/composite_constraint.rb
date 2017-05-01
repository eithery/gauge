# Eithery Lab, 2017
# Class Gauge::DB::Constraints::CompositeConstraint
# A base class for all composite (multicolumn) database constraints.

require 'gauge'
require_relative 'database_constraint'

module Gauge
  module DB
    module Constraints
      class CompositeConstraint < DatabaseConstraint
        attr_reader :columns

        def initialize(name, table:, columns:)
          super(name, table: table)
          @columns = flatten_array_of columns
        end


        def composite?
          columns.length > 1
        end


  protected

        def flatten_array_of(columns)
          [columns].flatten.map { |col| col.downcase.to_sym }
        end
      end
    end
  end
end
