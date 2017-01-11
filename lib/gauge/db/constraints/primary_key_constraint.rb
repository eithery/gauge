# Eithery Lab, 2017
# Class Gauge::DB::Constraints::PrimaryKeyConstraint
# A primary key constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class PrimaryKeyConstraint < CompositeConstraint
        def initialize(name, table:, columns:, clustered: true)
          super(name, table: table, columns: columns)
          @clustered = clustered
        end


        def clustered?
          @clustered
        end


        def ==(other_key)
          table == other_key.table && columns.sort == other_key.columns.sort && clustered? == other_key.clustered?
        end
      end
    end
  end
end
