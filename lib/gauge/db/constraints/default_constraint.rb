# Eithery Lab, 2017
# Class Gauge::DB::Constraints::DefaultConstraint
# A data column default constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class DefaultConstraint < DatabaseConstraint
        attr_reader :column, :default_value

        def initialize(name, table:, column:, default_value:)
          super(name, table: table)
          @column = column.to_sym.downcase
          @default_value = default_value
        end
      end
    end
  end
end
