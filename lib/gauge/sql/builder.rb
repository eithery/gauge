# Eithery Lab., 2015.
# Class Gauge::SQL::Builder
# Factory class used to build SQL queries.

require 'gauge'

module Gauge
  module SQL
    class Builder
      def initialize
        @mode = :alter_table
        @sql_home ||= File.expand_path(File.dirname(__FILE__) + '/../../../sql/')
        @columns_to_add = {}
        @columns_to_alter = {}
        @constraints_to_drop = {}
        @indexes_to_drop = []
        @foreign_keys = []
        @unique_constraints = []
        @indexes = []
      end


      def cleanup dbo
        dbo.class == Gauge::Schema::DatabaseSchema ? delete_database_sql(dbo) : delete_data_table_sql(dbo)
      end


      def create_table(table)
        @mode = :create_table
      end


      def add_column(column)
        @columns_to_add[column.to_sym] = column
      end


      def alter_column(column)
        @columns_to_alter[column.to_sym] = column
      end


      def drop_constraint(constraint)
        @constraints_to_drop[constraint.to_sym] = constraint
      end


      def add_primary_key(primary_key)
        @primary_key = primary_key
      end


      def add_foreign_key(foreign_key)
        @foreign_keys << foreign_key
      end


      def add_unique_constraint(unique_constraint)
        @unique_constraints << unique_constraint
      end


      def create_index(index)
        @indexes << index
      end


      def drop_index(index)
        @indexes_to_drop << index
      end


      def build_sql(table)
        sql = method("#{@mode}_sql").call(table)
        save sql, to: file_name_for(@mode, table) unless sql.blank?
      end

  private

      def create_table_clause(table)
        "create table #{table.sql_schema}.#{table.local_name}"
      end


      def alter_table_clause(table)
        "alter table #{table.sql_schema}.#{table.local_name}"
      end


      def add_column_clause(column)
        "add #{column.column_name} #{column.sql_attributes}#{default_value(column)};"
      end


      def alter_column_clause(column)
        "alter column #{column.column_name} #{column.sql_attributes};"
      end


      def add_primary_key_clause(primary_key)
        "add primary key#{clustered_clause(primary_key)} (#{primary_key.columns.join(', ')});"
      end


      def add_foreign_key_clause(foreign_key)
        "add foreign key (#{foreign_key.columns.join(', ')}) references #{foreign_key.ref_table_sql} " +
        "(#{foreign_key.ref_columns.join(', ')});"
      end


      def add_unique_constraint_clause(unique_constraint)
        "add unique (#{unique_constraint.columns.join(', ')});"
      end


      def create_index_clause(table, index)
        unique = index.unique? ? 'unique ' : ''
        clustered = index.clustered? ? 'clustered ' : ''
        "create #{unique}#{clustered}index #{index.name} on #{table.sql_schema}.#{table.local_name} " +
        "(#{index.columns.join(', ')});"
      end


      def clustered_clause(index)
        index.clustered? ? "" : " nonclustered"
      end


      def sql_home
        Dir.mkdir(@sql_home) unless File.exists? @sql_home
        @sql_home
      end


      def save(sql, options)
        file_name = options[:to]
        File.open(file_name, 'a') { |f| f.puts sql }
        sql
      end


      def table_home(table)
        database = create_folder "#{sql_home}/#{table.database_schema.sql_name}"
        tables = create_folder "#{database}/tables"
      end


      def create_folder(path)
        Dir.mkdir(path) unless File.exists? path
        path
      end


      def file_name_for(command, schema)
        "#{table_home(schema.table_schema)}/#{prefix(command)}_#{schema.table_schema.to_sym}.sql"
      end


      def prefix(command)
        command == :create_table ? 'create' : 'alter'
      end


      def default_value(column)
        " default #{column.sql_default_value}" unless column.sql_default_value.nil?
      end


      def delete_database_sql database
        database_path = "#{sql_home}/#{database.sql_name}"
        FileUtils.remove_dir database_path, force: true
      end


      def delete_data_table_sql table
        tables_path = "#{sql_home}/#{table.database_schema.sql_name}/tables"
        FileUtils.remove_file "#{tables_path}/create_#{table.to_sym}.sql", force: true
        FileUtils.remove_file "#{tables_path}/alter_#{table.to_sym}.sql", force: true
      end


      def create_table_sql(table)
        sql = []
        sql << "#{create_table_clause table}"
        sql << "("
        sql << ");"
        sql << "go\n"
        sql.join("\n")
      end


      def alter_table_sql(table)
        sql = []
        drop_indexes_on table, sql
        drop_constraints_on table, sql
        add_columns_on table, sql
        alter_columns_on table, sql
        add_primary_key_on table, sql
        add_unique_constraints_on table, sql
        add_foreign_keys_on table, sql
        create_indexes_on table, sql
        sql.join("\n")
      end


      def drop_constraints_on(table, sql)
        @constraints_to_drop.each do |key, constraint|
          sql << alter_table_clause(table)
          sql << "drop constraint #{constraint.name};"
          sql << "go\n"
        end
      end


      def drop_indexes_on(table, sql)
        @indexes_to_drop.each do |index|
          sql << "drop index #{index.name} on #{table.sql_schema}.#{table.local_name};"
          sql << "go\n"
        end
      end


      def add_columns_on(table, sql)
        @columns_to_add.each do |key, col|
          sql << alter_table_clause(table)
          sql << add_column_clause(col)
          sql << "go\n"
        end
      end


      def alter_columns_on(table, sql)
        @columns_to_alter.each do |key, col|
          sql << alter_table_clause(table)
          sql << alter_column_clause(col)
          sql << "go\n"
        end
      end


      def add_primary_key_on(table, sql)
        unless @primary_key.nil?
          sql << alter_table_clause(table)
          sql << add_primary_key_clause(@primary_key)
          sql << "go\n"
        end
      end


      def add_foreign_keys_on(table, sql)
        @foreign_keys.each do |fk|
          sql << "#{alter_table_clause table} with check"
          sql << add_foreign_key_clause(fk)
          sql << "go\n"
        end
      end


      def add_unique_constraints_on(table, sql)
        @unique_constraints.each do |constraint|
          sql << alter_table_clause(table)
          sql << add_unique_constraint_clause(constraint)
          sql << "go\n"
        end
      end


      def create_indexes_on(table, sql)
        @indexes.each do |index|
          sql << create_index_clause(table, index)
          sql << "go\n"
        end
      end
    end
  end
end
