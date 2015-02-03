# Eithery Lab., 2015.
# Class Gauge::DB::ForeignKey
# Represents the foreign key constraint.

require 'gauge'

module Gauge
  module DB
    class ForeignKey
      attr_reader :name, :table, :columns, :referenced_table, :referenced_columns

      def initialize(name, table, columns, referenced_table, referenced_columns)
        @name = name.downcase
        @table = table.to_s.gsub('.', '_').downcase.to_sym
        @columns = [columns].flatten.map { |col| col.downcase.to_sym }
        @referenced_table = referenced_table.to_s.gsub('.', '_').downcase.to_sym
        @referenced_columns = [referenced_columns].flatten.map { |col| col.downcase.to_sym }
      end
    end
  end
end
