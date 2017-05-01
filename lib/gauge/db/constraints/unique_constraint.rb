# Eithery Lab, 2017
# Class Gauge::DB::Constraints::UniqueConstraint
# A unique constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class UniqueConstraint < CompositeConstraint

        def initialize(name, table:, columns:)
          super
        end


        def ==(other_constraint)
          return false if other_constraint.nil?
          table == other_constraint.table && columns.sort == other_constraint.columns.sort
        end
      end
    end
  end
end
