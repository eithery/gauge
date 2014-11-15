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
        columns << DataColumnSchema.new(:id, type: :long, required: true) unless has_id?
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
        columns.any? { |col| col.column_name.downcase.to_sym == column_name.downcase.to_sym }
      end


      def col(*args)
        columns << DataColumnSchema.new(*args)
      end


      def timestamps(options={})
        columns << DataColumnSchema.new(:created, type: :datetime, required: true)
        columns << DataColumnSchema.new(created_by_column(options), required: true)
        columns << DataColumnSchema.new(:modified, type: :datetime, required: true)
        columns << DataColumnSchema.new(modified_by_column(options), required: true)
        columns << DataColumnSchema.new(:version, type: :long, required: true)
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
    end
  end
end
