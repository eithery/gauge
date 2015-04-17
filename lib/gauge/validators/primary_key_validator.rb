# Eithery Lab., 2015.
# Class Gauge::Validators::PrimaryKeyValidator
# Checks primary key constraint on the table.

require 'gauge'

module Gauge
  module Validators
    class PrimaryKeyValidator < Validators::Base

      validate do |table_schema, table, sql|
        case mismatch(table_schema.primary_key, table.primary_key)
          when :missing_primary_key
            errors << "Missing <b>primary key</b> on the data table."
            sql.add_primary_key table_schema.primary_key

          when :column_mismatch
            errors << "Primary key is defined on [#{columns(table.primary_key)}] " +
              "column".pluralize(table.primary_key.columns.count) +
              ", but it should be on [#{columns(table_schema.primary_key)}]."
            rebuild_primary_key table_schema, table, sql

          when :clustered_mismatch
            errors << "Primary key should be <b>#{clustered_msg(table_schema.primary_key)}</b>, " +
              "but actually it is <b>#{clustered_msg(table.primary_key)}</b>."
            rebuild_primary_key table_schema, table, sql
        end
      end

  private

      def mismatch(expected_key, actual_key)
        return :missing_primary_key if actual_key.nil?
        kind_of_mismatch(expected_key, actual_key) if expected_key != actual_key
      end


      def kind_of_mismatch(expected_key, actual_key)
        return :column_mismatch if expected_key.columns.sort != actual_key.columns.sort
        :clustered_mismatch if expected_key.clustered? != actual_key.clustered?
      end


      def clustered_msg(primary_key)
        primary_key.clustered? ? "clustered" : "nonclustered"
      end


      def columns(primary_key)
        primary_key.columns.map { |col| "'<b>#{col}</b>'" }.join(', ')
      end


      def rebuild_primary_key(table_schema, table, sql)
        sql.drop_constraint table.primary_key
        sql.add_primary_key table_schema.primary_key
      end
    end
  end
end
