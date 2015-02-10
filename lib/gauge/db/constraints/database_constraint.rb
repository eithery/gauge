# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::DatabaseConstraint
# Represents the base class for all database constraints.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class DatabaseConstraint
        attr_reader :name, :table, :columns

    protected

        def initialize(name, table, columns)
          @name = name.downcase
          @table = table_key_for table
          @columns = flatten_array_of columns
        end


        def table_key_for(table)
          table.to_s.gsub('.', '_').downcase.to_sym
        end


        def flatten_array_of(columns)
          [columns].flatten.map { |col| col.downcase.to_sym }
        end
      end
    end
  end
end
