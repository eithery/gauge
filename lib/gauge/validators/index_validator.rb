# Eithery Lab., 2015.
# Class Gauge::Validators::IndexValidator
# Checks indexes on the data table.

require 'gauge'

module Gauge
  module Validators
    class IndexValidator < Validators::Base

      validate do |table_schema, table|
        redundant_indexes = table.indexes.dup
        table_schema.indexes.each do |index|
          case mismatch(index, table)
            when :missing_index
              errors << "Missing #{description_of(index)}."
            when :unique_mismatch
              errors << mismatch_message(index, :unique, :nonunique)
            when :clustered_mismatch
              errors << mismatch_message(index, :clustered, :nonclustered)
          end
          actual_index = take_same_index_for(index, redundant_indexes)
          redundant_indexes.delete_if { |idx| idx.equal?(actual_index) } unless actual_index.nil?
        end

        redundant_indexes.each { |idx| errors << "Redundant #{description_of(idx)}." }
      end

  private

      def mismatch(index, table)
        actual_index = take_same_index_for(index, table.indexes)
        return :missing_index if actual_index.nil?
        return :clustered_mismatch if index.clustered? != actual_index.clustered?
        return :unique_mismatch if index.unique? != actual_index.unique?
      end


      def take_same_index_for(index, indexes)
        indexes.select { |idx| idx.columns.sort == index.columns.sort }.first
      end


      def columns_of(index)
        index.columns.map { |col| "'<b>#{col}</b>'" }.join(', ')
      end


      def kind_of(index)
        return "unique clustered index" if index.clustered?
        return "unique index" if index.unique?
        "index"
      end


      def description_of(index)
        "<b>#{kind_of(index)}</b> on [#{columns_of(index)}] data " + "column".pluralize(index.columns.count)
      end


      def mismatch_message(index, expected, actual)
        expected_method = method("#{expected.to_s.downcase}_message")
        actual_method = method("#{actual.to_s.downcase}_message")
        "Index on [#{columns_of(index)}] data " +
        "column".pluralize(index.columns.count) +
        " should be <b>#{expected_method.call(index)}</b>, but actually it is <b>#{actual_method.call(index)}</b>."
      end


      def clustered_message(index)
        index.clustered? ? "clustered" : "nonclustered"
      end


      def nonclustered_message(index)
        index.clustered? ? "nonclustered" : "clustered"
      end


      def unique_message(index)
        index.unique? ? "unique" : "not unique"
      end


      def nonunique_message(index)
        index.unique? ? "not unique" : "unique"
      end
    end
  end
end
