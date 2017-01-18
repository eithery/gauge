# Eithery Lab, 2017
# Class Sequel::TynyTDS::Database
# Extends Sequel Database functionality.

require 'sequel'
require 'gauge'

module Sequel
  module TinyTDS
    class Database < Sequel::Database

      def tables
        @tables ||= execute_sql(SQL_ALL_TABLES).map do |row|
          schema = row[:table_schema].downcase
          name = row[:table_name].downcase
          Gauge::DB::DataTable.new("#{schema}.#{name}", db: self)
        end
      end


      def views
        @views ||= execute_sql(SQL_ALL_VIEWS).map do |row|
          schema = row[:view_schema].downcase
          name = row[:view_name].downcase
          Gauge::DB::DataView.new("#{schema}.#{name}", sql: row[:view_sql], indexed: row[:is_indexed] == 1)
        end
      end


      def table_exists?(table_name)
        tables.any? { |table| table_keys_for(table_name).include?(table.to_sym) }
      end


      def table(table_name)
        tables.select { |table| table_keys_for(table_name).include?(table.to_sym) }.first
      end


      def primary_keys
        @primary_keys ||= all_constraints(SQL_ALL_PRIMARY_KEYS) do |name, row|
          Gauge::DB::Constraints::PrimaryKeyConstraint.new(name, table: table_from(row),
            columns: column_from(row), clustered: row[:key_type] != 2)
        end
      end


      def foreign_keys
        @foreign_keys ||= all_constraints(SQL_ALL_FOREIGN_KEYS, contains_refs: true) do |name, row|
          Gauge::DB::Constraints::ForeignKeyConstraint.new(name, table: table_from(row),
            columns: column_from(row), ref_table: ref_table_from(row), ref_columns: ref_column_from(row))
        end
      end


      def unique_constraints
        @unique_constraints ||= all_constraints(SQL_ALL_UNIQUE_CONSTRAINTS) do |name, row|
          Gauge::DB::Constraints::UniqueConstraint.new(name, table: table_from(row), columns: column_from(row))
        end
      end


      def check_constraints
        @check_constraints ||= all_constraints(SQL_ALL_CHECK_CONSTRAINTS) do |name, row|
          Gauge::DB::Constraints::CheckConstraint.new(name, table: table_from(row), columns: column_from(row),
            check: row[:check_clause])
        end
      end


      def default_constraints
        @default_constraints ||= all_constraints(SQL_ALL_DEFAULT_CONSTRAINTS) do |name, row|
          Gauge::DB::Constraints::DefaultConstraint.new(name, table: table_from(row), column: column_from(row),
            default_value: row[:definition])
        end
      end


      def indexes
        @indexes ||= all_constraints(SQL_ALL_INDEXES) do |name, row|
          Gauge::DB::Index.new(name, table: table_from(row), columns: column_from(row),
            unique: row[:is_unique] == true, clustered: row[:index_type] == 1)
        end
      end


  private

      def table_keys_for(table_name)
        [Gauge::Helpers::NameParser.dbo_key_of(table_name), table_name.downcase.to_sym]
      end


      def table_from(dataset_row)
        compose_table dataset_row, :table_schema, :table_name
      end


      def ref_table_from(dataset_row)
        compose_table dataset_row, :ref_table_schema, :ref_table_name
      end


      def compose_table(dataset_row, table_schema, table_name)
        "#{dataset_row[table_schema]}.#{dataset_row[table_name]}".downcase.to_sym
      end


      def column_from(dataset_row)
        compose_column dataset_row, :column_name
      end


      def ref_column_from(dataset_row)
        compose_column dataset_row, :ref_column_name
      end


      def compose_column(dataset_row, column_name)
        dataset_row[column_name].downcase.to_sym
      end


      def all_constraints(sql, contains_refs=false, &block)
        constraints = {}
        execute_sql(sql).map do |row|
          constraint_name = row[:constraint_name].downcase
          key = "#{constraint_name}_#{row[:table_schema]}_#{row[:table_name]}".downcase
          unless constraints.include?(key)
            constraints[key] = block.call(constraint_name, row)
          else
            constraints[key].columns << column_from(row)
            constraints[key].ref_columns << ref_column_from(row) if contains_refs
          end
        end
        constraints.values
      end


      def execute_sql(sql)
        self.[](sql).all
      end


      SQL_ALL_TABLES = <<~eos
        select t.name as table_name, s.name as table_schema
        from sys.tables as t
        inner join sys.schemas as s on s.schema_id = t.schema_id
      eos

      SQL_ALL_PRIMARY_KEYS = <<~eos
        select idx.name as constraint_name, s.name as table_schema, t.name as table_name,
          col.name as column_name, idx.type as key_type
        from sys.indexes as idx
        inner join sys.tables as t on t.object_id = idx.object_id
        inner join sys.schemas as s on s.schema_id = t.schema_id
        inner join sys.index_columns as ic on ic.object_id = idx.object_id and ic.index_id = idx.index_id
        inner join sys.columns as col on col.object_id = ic.object_id and col.column_id = ic.column_id
        where idx.is_primary_key = 1 and t.is_ms_shipped = 0;
      eos

      SQL_ALL_FOREIGN_KEYS = <<~eos
        select obj.name as constraint_name, sch.name as table_schema, t.name as table_name, col.name as column_name,
          refsch.name as ref_table_schema, reft.name as ref_table_name, refcol.name as ref_column_name
        from sys.foreign_key_columns as fkc
        inner join sys.objects as obj on obj.object_id = fkc.constraint_object_id
        inner join sys.tables as t on t.object_id = fkc.parent_object_id
        inner join sys.schemas as sch on sch.schema_id = t.schema_id
        inner join sys.columns as col on col.column_id = fkc.parent_column_id and col.object_id = t.object_id
        inner join sys.tables as reft on reft.object_id = fkc.referenced_object_id
        inner join sys.schemas as refsch on refsch.schema_id = reft.schema_id
        inner join sys.columns as refcol on refcol.column_id = fkc.referenced_column_id and refcol.object_id = reft.object_id;
      eos

      SQL_ALL_UNIQUE_CONSTRAINTS = <<~eos
        select tc.constraint_name, tc.table_schema, tc.table_name, col.column_name
        from information_schema.table_constraints as tc
        inner join information_schema.constraint_column_usage as col on col.constraint_name = tc.constraint_name
          and col.constraint_schema = tc.constraint_schema
        where tc.constraint_type = 'UNIQUE';
      eos

      SQL_ALL_CHECK_CONSTRAINTS = <<~eos
        select cc.constraint_name, col.table_schema, col.table_name, col.column_name, cc.check_clause
        from information_schema.check_constraints as cc
        inner join information_schema.constraint_column_usage col on cc.constraint_name = col.constraint_name;
      eos

      SQL_ALL_DEFAULT_CONSTRAINTS = <<~eos
        select dc.name as constraint_name, s.name as table_schema, t.name as table_name,
          col.name as column_name, dc.definition
        from sys.default_constraints as dc
        inner join sys.columns as col on col.object_id = dc.parent_object_id and col.column_id = dc.parent_column_id
        inner join sys.tables as t on t.object_id = col.object_id
        inner join sys.schemas as s on s.schema_id = t.schema_id;
      eos

      SQL_ALL_INDEXES = <<~eos
        select idx.name as constraint_name, s.name as table_schema, t.name as table_name, col.name as column_name,
          idx.is_unique, idx.[type] as index_type
        from sys.indexes as idx
        inner join sys.tables as t on t.object_id = idx.object_id
        inner join sys.schemas as s on s.schema_id = t.schema_id
        inner join sys.index_columns as ic on ic.object_id = idx.object_id and ic.index_id = idx.index_id
        inner join sys.columns as col on col.object_id = ic.object_id and col.column_id = ic.column_id
        where idx.is_primary_key = 0 and idx.is_unique_constraint = 0 and t.is_ms_shipped = 0;
      eos

      SQL_ALL_VIEWS = <<~eos
        select v.name as view_name, s.name as view_schema,
        objectpropertyex(object_id, 'IsIndexed') as is_indexed, isv.view_definition as view_sql
        from sys.views as v
        inner join sys.schemas as s on s.schema_id = v.schema_id
        inner join information_schema.views as isv on isv.table_name = v.name and isv.table_schema = s.name;
      eos
    end
  end
end
