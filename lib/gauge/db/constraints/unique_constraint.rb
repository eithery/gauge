# Eithery Lab, 2017
# Class Gauge::DB::Constraints::UniqueConstraint
# A unique constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class UniqueConstraint < CompositeConstraint

        def initialize(name:, table:, columns:)
          super
        end
      end
    end
  end
end
