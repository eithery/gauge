# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::UniqueConstraint
# Represents the unique constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class UniqueConstraint < DatabaseConstraint

        def initialize(name, table, columns)
          super
        end
      end
    end
  end
end
