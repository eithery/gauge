# Eithery Lab, 2017
# Class Gauge::Schema::DataTableSchema
# Data table schema
# Contains metadata info defining a data table structure.

require 'gauge'

module Gauge
  module Schema
    class DataTableSchema
      include Gauge::Helpers
      include Gauge::Helpers::NamesHelper

      attr_reader :sql_schema, :database, :columns

      def initialize(name:, sql_schema: nil, db:, table_type: nil, &block)
        @local_name = local_name_of(name)
        @sql_schema = sql_schema || sql_schema_of(name).to_sym
        @database = db.to_s.downcase.to_sym
        @table_type = table_type
        @columns = []

        instance_eval(&block) if block
        define_surrogate_id unless has_id?
      end


      def table_id
        "#{sql_schema}_#{local_name}".downcase.to_sym
      end

      alias_method :to_sym, :table_id


      def table_name
        "#{sql_schema}.#{local_name}"
      end

      alias_method :sql_name, :table_name


      def local_name
        @local_name.to_s
      end


      def object_name
        'Data table'
      end


      def reference_table?
        sql_schema == :ref || @table_type == :reference
      end


      def contains_column?(column_name)
        columns.any? { |col| col.column_id == column_name.to_s.downcase.to_sym }
      end


      def column(column_name)
        columns.select { |col| col.column_id == column_name.to_s.downcase.to_sym }.first
      end

      alias_method :[], :column


      def col(name=nil, options={})
        if name.kind_of? Hash
          options = name
          name = nil
        end
        columns << DataColumnSchema.new({ name: name, table: self }.merge(options))
      end


      def timestamps(*overrides)
        timestamp_columns = [
          { name: column_name_for(:created_at, overrides), type: :datetime, required: true },
          { name: column_name_for(:updated_at, overrides), type: :datetime, required: true },
          { name: column_name_for(:created_by, overrides), required: true },
          { name: column_name_for(:updated_by, overrides), required: true },
          { name: :version, type: :int }
        ]
        timestamp_columns.each { |col| columns << DataColumnSchema.new(col) }
      end


      def primary_key
        @primary_key ||= define_primary_key
      end


      def indexes
        @indexes ||= define_indexes + define_business_id + define_indexes_on_foreign_keys
      end


      def index(columns, unique: false, clustered: false)
        index_name = "idx_#{table_id}_" + constraint_columns(columns).map { |col| col.to_s.downcase }.join('_')
        indexes << Gauge::DB::Index.new(index_name, table: table_name, columns: columns,
          unique: unique, clustered: clustered)
      end


      def unique_constraints
        @unique_constraints ||= define_unique_constraints
      end


      def unique(columns)
        constraint_name = "uc_#{table_id}_" + constraint_columns(columns).map { |col| col.to_s.downcase }.join('_')
        unique_constraints << Gauge::DB::Constraints::UniqueConstraint.new(constraint_name, table: table_name,
          columns: columns)
      end


      def foreign_keys
        @foreign_keys ||= define_foreign_keys
      end


      def foreign_key(columns, ref_table:, ref_columns:)
        ref_table_id = dbo_id(ref_table)
        constraint_name = "fk_#{table_id}_#{ref_table_id}_#{constraint_columns(columns).join('_')}"
        foreign_keys << Gauge::DB::Constraints::ForeignKeyConstraint.new(constraint_name, table: table_name,
          columns: columns, ref_table: ref_table, ref_columns: ref_columns)
      end


      def cleanup_sql_files
        remove_file :create
        remove_file :alter
        remove_file :drop
      end


private

      def has_id?
        columns.any? { |c| c.id? }
      end


      def column_name_for(column_name, overrides)
        overridden_name = overrides.select { |col| timestamp_columns[column_name].include?(col.to_s.downcase.to_sym) }.first
        overridden_name.nil? ? column_name : overridden_name
      end


      def timestamp_columns
        @timestamp_columns ||= {
          created_at: [:created],
          created_by: [:createdby],
          updated_at: [:updated, :updatedat, :modified, :modifiedat, :modified_at],
          updated_by: [:updatedby, :modifiedby, :modified_by]
        }
      end


      def define_surrogate_id
        col :id, required: true, id: true
      end


      def define_primary_key
        has_clustered_index = indexes.any? { |idx| idx.clustered? }
        key_columns = columns.select { |col| col.id? }.map { |col| col.column_id }
        DB::Constraints::PrimaryKeyConstraint.new("pk_#{table_id}", table: table_name, columns: key_columns,
          clustered: !has_clustered_index)
      end


      def define_indexes
        columns.select { |col| col.has_index? }.map { |col| col.index }
      end


      def define_unique_constraints
        columns.select { |col| col.has_unique_constraint? }.map { |col| col.unique_constraint }
      end


      def define_foreign_keys
        columns.select { |col| col.has_foreign_key? }.map { |col| col.foreign_key }
      end


      def define_indexes_on_foreign_keys
        foreign_keys.map do |foreign_key|
          Gauge::DB::Index.new("idx_#{table_id}_#{foreign_key.columns.join('_')}", table: table_name,
            columns: foreign_key.columns)
        end
      end


      def define_business_id
        business_key_columns = columns.select { |col| col.business_id? }.map { |col| col.column_id }
        return [] unless business_key_columns.any?

        index_name = "idx_#{table_id}_" + business_key_columns.each { |col| col.to_s }.join('_')
        [DB::Index.new(index_name, table: table_name, columns: business_key_columns, clustered: true)]
      end


      def constraint_columns(columns)
        cols = [columns].flatten
        verify_columns(cols)
        cols
      end


      def verify_columns(columns)
        columns.each do |col|
          unless contains_column?(col)
            raise Errors::InvalidMetadataError, "Missing column '#{col}' in #{table_name} data table."
          end
        end
      end


      def remove_file(kind)
        tables_path = "#{ApplicationHelper.sql_home}/#{database}/tables"
        FileUtils.remove_file("#{tables_path}/#{kind.to_s}_#{table_id}.sql", force: true)
      end
    end
  end
end
