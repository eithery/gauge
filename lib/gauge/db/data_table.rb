# Eithery Lab, 2017
# Class Gauge::DB::DataTable
# An actual database table.

require 'gauge'

module Gauge
  module DB
    class DataTable < DatabaseObject
      def initialize(name, db:)
        super(name)
        @database = db
      end


      def columns
        local_name = name.split('.').last
        @columns ||= @database.schema(local_name).map do |column_name, options|
          DataColumn.new(column_name, options)
        end
      end


      def column_exists?(column_name)
        columns.any? { |col| col.to_sym == key_of(column_name) }
      end


      def column(column_name)
        columns.select { |col| col.to_sym == key_of(column_name) }.first
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


  private

      def key_of(column_name)
        column_name.downcase.to_sym
      end
    end
  end
end
