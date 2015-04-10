# Eithery Lab., 2015.
# Class Gauge::Validators::UniqueConstraintValidator
# Checks unique constraints on the data table.

require 'gauge'

module Gauge
  module Validators
    class UniqueConstraintValidator < Validators::Base

      validate do |table_schema, table|
        redundant_constraints = table.unique_constraints.dup
        table_schema.unique_constraints.each do |constraint|
          errors << "Missing #{description_of(constraint)}." if missing?(constraint, table)
          actual_constraint = take_same_constraint_for(constraint, redundant_constraints)
          redundant_constraints.delete_if { |uc| uc.equal?(actual_constraint) } unless actual_constraint.nil?
        end

        redundant_constraints.each { |uc| errors << "Redundant #{description_of(uc)}." }
      end

  private

      def missing?(constraint, table)
        take_same_constraint_for(constraint, table.unique_constraints).nil?
      end


      def description_of(constraint)
        "<b>unique constraint</b> on [#{columns_of(constraint)}] data " + "column".pluralize(constraint.columns.count)
      end


      def columns_of(constraint)
        constraint.columns.map { |col| "'<b>#{col}</b>'" }.join(', ')
      end


      def take_same_constraint_for(constraint, constraints)
        constraints.select { |uc| uc.columns.sort == constraint.columns.sort }.first
      end
    end
  end
end
