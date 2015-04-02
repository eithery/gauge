# Eithery Lab., 2015.
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
        "#{sql_schema}.#{local_name}"
      end


      def local_name
        @local_name.to_s
      end


      def object_name
        'Data table'
      end


      def sql_schema
        @options[:sql_schema] || :dbo
      end


      def sql_name
        table_name
      end


      def database_schema
        @options[:database]
      end


      def reference_table?
        @options[:type] == :reference || sql_schema == :ref
      end


      def to_sym
        "#{sql_schema}_#{local_name}".downcase.to_sym
      end


      def contains?(column_name)
        columns.any? { |col| col.to_sym == column_name.downcase.to_sym }
      end


      def col(*args, &block)
        columns << DataColumnSchema.new(*args, &block).in_table(self)
      end


      def timestamps(options={})
        {
          created_at_column(options) => { type: :datetime },
          created_by_column(options) => { type: :string },
          modified_at_column(options) => { type: :datetime },
          modified_by_column(options) => { type: :string },
          version: { type: :long, default: 0 }
        }
        .each { |name, options| col name, type: options[:type], required: true, default: options[:default] }
      end


      def index(columns, options={})
      end


      def primary_key
        @primary_key ||= define_primary_key
      end

private

      def has_id?
        columns.any? { |c| c.id? }
      end


      def created_at_column(options)
        options[:dates] == :short ? :created : :created_at
      end


      def created_by_column(options)
        options[:naming] == :camel ? :createdBy : :created_by
      end


      def modified_at_column(options)
        options[:dates] == :short ? :modified : :modified_at
      end


      def modified_by_column(options)
        options[:naming] == :camel ? :modifiedBy : :modified_by
      end


      def define_surrogate_id
        col :id, required: true, id: true
      end


      def define_primary_key
        options = {}
        options[:clustered] = false if columns.any? { |col| col.business_id? }
        key_columns = columns.select { |col| col.id? }.map { |col| col.to_sym }
        DB::Constraints::PrimaryKeyConstraint.new("pk_#{to_sym}", table_name, key_columns, options)
      end
    end
  end
end
