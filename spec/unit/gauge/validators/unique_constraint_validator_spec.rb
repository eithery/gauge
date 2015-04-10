# Eithery Lab., 2015.
# Gauge::Validators::UniqueConstraintValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe UniqueConstraintValidator do
      let(:validator) { UniqueConstraintValidator.new }
      let(:schema) { @table_schema }
      let(:table) { double('table', unique_constraints: @unique_constraints) }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        context "for the unique constraints defined on one column" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10, unique: true
            end
          end

          context "existing on the data table" do
            before do
              @unique_constraints = [Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_12345',
                :reps, :rep_code)]
            end
            it { should_not_yield_errors }
          end

          context "missing on the data table" do
            before { @unique_constraints = [] }
            it { yields_error :missing_constraint, columns: [:rep_code] }
          end

          context "defined on another column" do
            before do
              @unique_constraints = [Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_rep_code',
                :reps, :rep_name)]
            end
            it { yields_error :missing_constraint, columns: [:rep_code] }
          end
        end

        context "for composite unique constraints" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10
              col :office_code, len: 10
              unique [:rep_code, :office_code]
            end
          end

          context "existing on the data table" do
            before do
              @unique_constraints = [Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_12345',
                :reps, [:rep_code, :office_code])]
            end
            it { should_not_yield_errors }
          end

          context "missing on the data table" do
            before { @unique_constraints = [] }
            it { yields_error :missing_constraint, columns: [:rep_code, :office_code] }
          end

          context "with missing one column in the actual constraint" do
            before do
              @unique_constraints = [Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_rep_code',
                :reps, [:rep_code])]
            end
            it { yields_error :missing_constraint, columns: [:rep_code, :office_code] }
          end

          context "including one extra column" do
            before do
              @unique_constraints = [Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_rep_code',
                :reps, [:rep_code, :office_code, :effective_date])]
            end
            it { yields_error :missing_constraint, columns: [:rep_code, :office_code] }
          end

          context "defined on same columns but in different order" do
            before do
              @unique_constraints = [Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_12345',
                :reps, [:office_code, :rep_code])]
            end
            it { should_not_yield_errors }
          end
        end

        context "for redundant unique constraints" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10
              col :office_code, len: 10
            end
            @unique_constraints = [
              Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_rep_code', :reps, :rep_code),
              Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_office_code', :reps, :office_code)]
          end

          it { yields_error :redundant_unique_constraint, columns: [:rep_code] }
          it { yields_error :redundant_unique_constraint, columns: [:office_code] }
        end
      end

  private

      def dba
        table
      end


      def missing_constraint_message(options)
        /Missing #{constraint_description(options)}/
      end


      def redundant_unique_constraint_message(options)
        /Redundant #{constraint_description(options)}/
      end


      def constraint_description(options)
        columns = options[:columns]
        "(.*?)unique constraint(.*?) on \\[#{displayed_names_of(columns)}\\] data " +
        "column".pluralize(columns.count)
      end
    end
  end
end
