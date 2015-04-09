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
              errors << "Missing <b>#{kind_of(index)}</b> on [#{columns(index)}] data " +
                "column".pluralize(index.columns.count) + "."
            when :unique_mismatch
              errors << "Index on [#{columns(index)}] data " +
                "column".pluralize(index.columns.count) +
                " should be <b>#{unique_msg(index)}</b>, but actually it is <b>#{nonunique_msg(index)}</b>."
            when :clustered_mismatch
              errors << "Index on [#{columns(index)}] data " +
                "column".pluralize(index.columns.count) +
                " should be <b>#{clustered_msg(index)}</b>, but actually it is <b>#{nonclustered_msg(index)}</b>."
          end
        end
      end

  private

      def mismatch(index, table)
        actual_index = table.indexes.select { |idx| idx.columns.sort == index.columns.sort }.first
        return :missing_index if actual_index.nil?
        return :clustered_mismatch if index.clustered? != actual_index.clustered?
        return :unique_mismatch if index.unique? != actual_index.unique?
      end


      def columns(index)
        index.columns.map { |col| "'<b>#{col}</b>'" }.join(', ')
      end


      def kind_of(index)
        return "unique clustered index" if index.clustered?
        return "unique index" if index.unique?
        "index"
      end


      def clustered_msg(index)
        index.clustered? ? "clustered" : "nonclustered"
      end


      def nonclustered_msg(index)
        index.clustered? ? "nonclustered" : "clustered"
      end


      def unique_msg(index)
        index.unique? ? "unique" : "not unique"
      end


      def nonunique_msg(index)
        index.unique? ? "not unique" : "unique"
      end
    end
  end
end
