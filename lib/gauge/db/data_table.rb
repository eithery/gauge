# Eithery Lab, 2017
# Class Gauge::DB::DataTable
# An actual database table.

require 'gauge'

module Gauge
  module DB
    class DataTable < DatabaseObject
      include Gauge::Helpers::NamesHelper

      def initialize(name:, db:)
        super(name: name)
        @database = db
      end


      def table_id
        dbo_id(name)
      end

      alias_method :to_sym, :table_id


      def columns
        local_name = name.split('.').last
        @columns ||= @database.schema(local_name).map do |column_name, column_options|
          DataColumn.new(name: column_name, options: column_options)
        end
      end


      def column_exists?(column_name)
        columns.any? { |col| col.column_id == column_name.to_s.downcase.to_sym }
      end


      def column(column_name)
        columns.select { |col| col.column_id == column_name.to_s.downcase.to_sym }.first
      end


      def primary_key
        @database.primary_keys.select { |pk| pk.table == table_id }.first
      end


      def foreign_keys
        @database.foreign_keys.select { |fk| fk.table == table_id }
      end


      def unique_constraints
        @database.unique_constraints.select { |uc| uc.table == table_id }
      end


      def check_constraints
        @database.check_constraints.select { |cc| cc.table == table_id }
      end


      def default_constraints
        @database.default_constraints.select { |dc| dc.table == table_id }
      end


      def indexes
        @database.indexes.select { |idx| idx.table == table_id }
      end
    end
  end
end
