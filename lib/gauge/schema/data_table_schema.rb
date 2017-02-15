# Eithery Lab, 2017
# Class Gauge::Schema::DataTableSchema
# Data table schema
# Contains metadata info defining a data table structure.

require 'gauge'

module Gauge
  module Schema
    class DataTableSchema
      attr_reader :sql_schema, :columns

      def initialize(table_name, sql_schema: :dbo, table_type: nil, &block)
        @local_name = table_name
        @columns = []
        @sql_schema = sql_schema
        @table_type = table_type

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


      def sql_name
        table_name
      end


      def reference_table?
        sql_schema == :ref || @table_type == :reference
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
        .each do |name, options|
          col name, type: options[:type], required: true, default: options[:default]
        end
      end


      def index(columns, unique: false, clustered: false)
        index_columns = [columns].flatten
        index_columns.each { |col| raise "Missing column '#{col}' in #{table_name} data table." unless contains?(col) }
        index_name = "idx_#{to_sym}_" + index_columns.map { |col| col.to_s.downcase }.join('_')
        indexes << Gauge::DB::Index.new(index_name, table: table_name, columns: columns, unique: unique, clustered: clustered)
      end


      def unique(columns)
        constraint_columns = [columns].flatten
        constraint_columns.each { |col| raise "Missing column '#{col}' in #{table_name} data table." unless contains?(col) }
        constraint_name = "uc_#{to_sym}_" + constraint_columns.map { |col| col.to_s.downcase }.join('_')
        unique_constraints << Gauge::DB::Constraints::UniqueConstraint.new(constraint_name, table: table_name, columns: columns)
      end


      def primary_key
        @primary_key ||= define_primary_key
      end


      def indexes
        @indexes ||= define_indexes + define_business_id + define_indexes_on_foreign_keys
      end


      def unique_constraints
        @unique_constraints ||= define_unique_constraints
      end


      def foreign_keys
        @foreign_keys ||= define_foreign_keys
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
        has_clustered_index = indexes.any? { |idx| idx.clustered? }
        key_columns = columns.select { |col| col.id? }.map { |col| col.to_sym }
        DB::Constraints::PrimaryKeyConstraint.new("pk_#{to_sym}", table: table_name, columns: key_columns, clustered: !has_clustered_index)
      end


      def define_indexes
        columns.select { |col| col.has_index? }.map { |col| col.index }
      end


      def define_unique_constraints
        columns.select { |col| col.has_unique_constraint? }.map { |col| col.unique_constraint }
      end


      def define_business_id
        business_key_columns = columns.select { |col| col.business_id? }.map { |col| col.to_sym }
        return [] unless business_key_columns.any?

        index_name = "idx_#{to_sym}_" + business_key_columns.each { |col| col.to_s }.join('_')
        [DB::Index.new(index_name, table: table_name, columns: business_key_columns, clustered: true)]
      end


      def define_foreign_keys
        columns.select { |col| col.has_foreign_key? }.map { |col| col.foreign_key }
      end


      def define_indexes_on_foreign_keys
        foreign_keys.map do |foreign_key|
          Gauge::DB::Index.new("idx_#{to_sym}_#{foreign_key.columns.join('_')}", table: table_name, columns: foreign_key.columns)
        end
      end
    end
  end
end
