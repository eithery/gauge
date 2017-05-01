# Eithery Lab, 2017
# Class Gauge::DB::Constraints::DatabaseConstraint
# A base class for all database constraints.

require 'gauge'
require_relative '../database_object'
require_relative '../../helpers/names_helper'

module Gauge
  module DB
    module Constraints
      class DatabaseConstraint < Gauge::DB::DatabaseObject
        include Gauge::Helpers::NamesHelper

        attr_reader :table

        def initialize(name:, table:)
          super(name: name)
          @table = dbo_id(table)
        end


        def ==(other_constraint)
          return false if other_constraint.nil?
          table == other_constraint.table
        end
      end
    end
  end
end
