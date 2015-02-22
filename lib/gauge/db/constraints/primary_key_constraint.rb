# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::PrimaryKeyConstraint
# Represents the primary key constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class PrimaryKeyConstraint < CompositeConstraint

        def initialize(name, table, columns, options={})
          super(name, table, columns)
          @clustered = options[:clustered] != false
        end


        def clustered?
          @clustered
        end
      end
    end
  end
end
