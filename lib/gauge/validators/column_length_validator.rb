# Eithery Lab., 2014.
# Class Gauge::Validators::ColumnLengthValidator
# Checks length for string type data columns.
require 'gauge'

module Gauge
  module Validators
    class ColumnLengthValidator < Validators::Base

      validate do |column_schema, db_column|
        if length_mismatch? column_schema, db_column
          build_sql(:alter_column, column_schema) do |sql|
            sql.alter_table column_schema.table
            sql.alter_column column_schema
          end

          errors << "The length of column '<b>#{column_schema.column_name}</b>' is '<b>#{db_column.length}</b>', " +
            "but it must be '<b>#{column_schema.length}</b>' chars."
        end
      end

  private

      def length_mismatch?(column_schema, db_column)
        return false if column_schema.computed?
        return false unless column_schema.char_column?
        char_length_mismatch?(column_schema, db_column)
      end


      def char_length_mismatch?(column_schema, db_column)
        return false if db_column.length == -1 && column_schema.length == :max
        column_schema.length != db_column.length
      end
    end
  end
end
