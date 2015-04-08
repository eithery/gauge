# Eithery Lab., 2015.
# Class Gauge::Validators::IndexValidator
# Checks indexes on the data table.

require 'gauge'

module Gauge
  module Validators
    class IndexValidator < Validators::Base

      validate do |table_schema, table|
        table_schema.indexes.each do |index|
          case mismatch(index, table)
            when :missing_index
              errors << "Missing <b>#{kind_of(index)}</b> on [#{columns(index)}] data column(s)."
          end
        end
      end

  private

      def mismatch(index, table)
        return :missing_index unless table.indexes.any? { |idx| idx == index }
      end


      def columns(index)
        index.columns.map { |col| "'<b>#{col}</b>'" }.join(', ')
      end


      def kind_of(index)
        return "unique clustered index" if index.clustered?
        return "unique index" if index.unique?
        "index"
      end
    end
  end
end
