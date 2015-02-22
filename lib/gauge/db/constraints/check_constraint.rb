# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::CheckConstraint
# Represents the data table check constraint.

require 'gauge'
require_relative 'composite_constraint'

module Gauge
  module DB
    module Constraints
      class CheckConstraint < CompositeConstraint
        attr_reader :check_expression


        def initialize(name, table, column, check_expression)
          super(name, table, column)
          @check_expression = check_expression
        end
      end
    end
  end
end
