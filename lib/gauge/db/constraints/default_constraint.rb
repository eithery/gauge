# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::DefaultConstraint
# Represents the data column default constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class DefaultConstraint < DatabaseConstraint
        attr_reader :column, :default_value

        def initialize(name, table, column, default_value)
          super(name, table)
          @column = column.to_sym.downcase
          @default_value = default_value
        end
      end
    end
  end
end
