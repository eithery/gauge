# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::DefaultConstraint
# Represents the data column default constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class DefaultConstraint < DatabaseConstraint
        attr_reader :default_value


        def initialize(name, table, columns, default_value)
          super(name, table, columns)
          @default_value = default_value
        end
      end
    end
  end
end
