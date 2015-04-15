# Eithery Lab., 2015.
# Class Gauge::Validators::ColumnLengthValidator
# Checks length for string type data columns.

require 'gauge'

module Gauge
  module Validators
    class ColumnLengthValidator < Validators::Base

      validate do |column_schema, column, sql|
        if length_mismatch? column_schema, column
          sql.alter_column column_schema

          errors << "The length of column '<b>#{column_schema.column_name}</b>' is '<b>#{column.length}</b>', " +
            "but it must be '<b>#{column_schema.length}</b>' chars."
        end
      end

  private

      def length_mismatch?(column_schema, column)
        return false if column_schema.computed?
        return false unless column_schema.char_column?
        char_length_mismatch?(column_schema, column)
      end


      def char_length_mismatch?(column_schema, column)
        return false if column.length == -1 && column_schema.length == :max
        column_schema.length != column.length
      end
    end
  end
end
