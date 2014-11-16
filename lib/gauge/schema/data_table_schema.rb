# Eithery Lab., 2014.
# Class Gauge::Schema::DataTableSchema
# Data table schema.
# Contains metadata info defining a data table structure.
require 'gauge'

module Gauge
  module Schema
    class DataTableSchema
      attr_reader :columns

      def initialize(table_name, options={}, &block)
        @local_name = table_name
        @options = options
        @columns = []

        instance_eval(&block) if block
        define_surrogate_id unless has_id?
      end


      def table_name
        "[#{sql_schema}].[#{local_name}]"
      end


      def local_name
        @local_name.to_s
      end


      def sql_schema
        @options[:sql_schema] || :dbo
      end


      def to_key
        "#{sql_schema}_#{local_name}".downcase.to_sym
      end


      def contains?(column_name)
        columns.any? { |col| col.to_key == column_name.downcase.to_sym }
      end


      def col(*args)
        column = DataColumnSchema.new(*args)
        column.table_name = local_name
        columns << column
      end


      def timestamps(options={})
        {
          created: :datetime,
          created_by_column(options) => :string,
          modified: :datetime,
          modified_by_column(options) => :string,
          version: :long
        }
        .each { |name, type| col name, type: type, required: true }
      end

private

      def has_id?
        columns.any? { |c| c.id? }
      end


      def created_by_column(options)
        options[:casing] == :camel ? :createdBy : :created_by
      end


      def modified_by_column(options)
        options[:casing] == :camel ? :modifiedBy : :modified_by
      end


      def define_surrogate_id
        col :id, type: :long, required: true
      end
    end
  end
end
