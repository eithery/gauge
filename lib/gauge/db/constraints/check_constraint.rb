# Eithery Lab, 2017
# Class Gauge::DB::Constraints::CheckConstraint
# A check constraint defined on data table.

require 'gauge'
require_relative 'composite_constraint'

module Gauge
  module DB
    module Constraints
      class CheckConstraint < CompositeConstraint
        attr_reader :expression

        def initialize(name, table:, columns:, check:)
          super(name, table: table, columns: columns)
          @expression = check
        end
      end
    end
  end
end
