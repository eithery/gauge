# Eithery Lab, 2017
# Class Gauge::DB::Constraints::DatabaseConstraint
# A base class for all database constraints.

require 'gauge'
require_relative '../database_object'

module Gauge
  module DB
    module Constraints
      class DatabaseConstraint < Gauge::DB::DatabaseObject
        attr_reader :table

        def initialize(name, table:)
          super(name)
          @table = Gauge::Helpers::NameParser.dbo_key_of table
        end
      end
    end
  end
end
