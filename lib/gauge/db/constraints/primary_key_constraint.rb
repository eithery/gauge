# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::PrimaryKeyConstraint
# Represents the primary key constraint.

require 'gauge'

module Gauge
  module DB
    module Constraints
      class PrimaryKeyConstraint
        attr_reader :name, :table, :columns

        def initialize(name, table, columns, options={})
          @name = name.downcase
          @table = table.to_s.gsub('.', '_').downcase.to_sym
          @columns = [columns].flatten.map { |col| col.downcase.to_sym }
          @clustered = options[:clustered] != false
        end


        def clustered?
          @clustered
        end


        def composite?
          columns.length > 1
        end
      end
    end
  end
end
