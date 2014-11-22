# Eithery Lab., 2014.
# Class Gauge::Validators::ColumnLengthValidator
# Checks length for string type data columns.
require 'gauge'

module Gauge
  module Validators
    class ColumnLengthValidator < Validators::Base

      validate do |column_schema, db_column|
        len = db_column[:max_chars]

        if length_mismatch? column_schema, len

          errors << "The length of column '".color(:red) +  column_schema.column_name.to_s.color(:red).bright +
            "' is '".color(:red) + "#{len}".color(:red).bright + "', but it must be '".color(:red) +
            "#{column_schema.length}".color(:red).bright + "' chars.".color(:red)
        end
      end

  private

      def length_mismatch?(column_schema, length)
        return false unless column_schema.char_column?
        char_length_mismatch?(column_schema, length)
      end


      def char_length_mismatch?(column_schema, length)
        return false if length == -1 && column_schema.length == :max
        column_schema.length != length
      end
    end
  end
end
