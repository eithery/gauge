# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::CheckConstraint
# Represents the check constraint defined on the data table.

require 'gauge'
require_relative 'composite_constraint'

module Gauge
  module DB
    module Constraints
      class CheckConstraint < CompositeConstraint
        attr_reader :expression

        def initialize(name, table, columns, expression)
          super(name, table, columns)
          @expression = expression
        end
      end
    end
  end
end
