# Eithery Lab., 2015.
# Class Gauge::DB::DataTable
# Represents the actual data table.

require 'gauge'

module Gauge
  module DB
    class DataTable < DatabaseObject
      def initialize(name, database)
        super(name)
        @database = database
      end


      def columns
        @columns ||= @database.schema(name).map do |column_name, options|
          DataColumn.new(column_name, options)
        end
      end


      def primary_key
        @database.primary_keys.select { |pk| pk.table == to_sym }.first
      end


      def foreign_keys
        @database.foreign_keys.select { |fk| fk.table == to_sym }
      end


      def unique_constraints
        @database.unique_constraints.select { |uc| uc.table == to_sym }
      end


      def check_constraints
        @database.check_constraints.select { |cc| cc.table == to_sym }
      end


      def default_constraints
        @database.default_constraints.select { |dc| dc.table == to_sym }
      end


      def indexes
        @database.indexes.select { |idx| idx.table == to_sym }
      end


      def to_sym
        Gauge::Helpers::NameParser.dbo_key_of name
      end
    end
  end
end
