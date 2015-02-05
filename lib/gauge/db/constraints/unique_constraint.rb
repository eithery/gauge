# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::UniqueConstraint
# Represents the unique constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class UniqueConstraint
        attr_reader :name, :table, :columns

        def initialize(name, table, columns)
          @name = name.downcase
          @table = table.to_s.gsub('.', '_').downcase.to_sym
          @columns = [columns].flatten.map { |col| col.downcase.to_sym }
        end
      end
    end
  end
end
