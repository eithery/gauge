# Eithery Lab., 2015.
# Class Gauge::Validators::ForeignKeyValidator
# Checks foreign key constraints on the table.

require 'gauge'

module Gauge
  module Validators
    class ForeignKeyValidator < Validators::Base

      validate do |table_schema, table, sql|
        table_schema.foreign_keys.each do |expected_key|
          actual_key = foreign_key_on(table, expected_key.columns)
          case mismatch(expected_key, actual_key)
            when :missing_foreign_key
              errors << "<b>Missing</b> #{description_of(expected_key)}"
            when :ref_table_mismatch
              errors << ref_table_mismatch_message(expected_key, actual_key)
            when :ref_columns_mismatch
              errors << ref_columns_mismatch_message(expected_key, actual_key)
          end
        end
      end

  private

      def mismatch(expected, actual)
        return :missing_foreign_key if actual.nil?
        return :ref_table_mismatch unless actual.ref_table == expected.ref_table
        return :ref_columns_mismatch unless actual.ref_columns.sort == expected.ref_columns.sort
      end


      def description_of(foreign_key)
        "<b>foreign key</b> on [#{displayed_names_of(foreign_key.columns)}] " +
        "column".pluralize(foreign_key.columns.count) +
        " references to ['<b>#{foreign_key.ref_table}</b>'].[#{displayed_names_of(foreign_key.ref_columns)}]."
      end


      def foreign_key_on(table, columns)
        table.foreign_keys.select { |fk| fk.columns.sort == columns.sort }.first
      end


      def displayed_names_of(columns)
        columns.map { |col| "'<b>#{col}</b>'" }.join(', ')
      end


      def ref_table_mismatch_message(expected, actual)
        "<b>Foreign key</b> on [#{displayed_names_of(actual.columns)}] " +
        "column".pluralize(actual.columns.count) + " references to ['<b>#{actual.ref_table}</b>'] data table, " +
        "but should be to ['<b>#{expected.ref_table}</b>'] one."
      end


      def ref_columns_mismatch_message(expected, actual)
        "<b>Foreign key</b> on [#{displayed_names_of(actual.columns)}] " +
        "column".pluralize(actual.columns.count) +
        " references to [#{displayed_names_of(actual.ref_columns)}] " +
        "column".pluralize(actual.ref_columns.count) +
        ", but should be to [#{displayed_names_of(expected.ref_columns)}]."
      end
    end
  end
end
