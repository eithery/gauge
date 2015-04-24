# Eithery Lab., 2015.
# Gauge::Validators::UniqueConstraintValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe UniqueConstraintValidator do
      let(:validator) { UniqueConstraintValidator.new }
      let(:schema) { @table_schema }
      let(:table) { double('table', unique_constraints: @unique_constraints) }
      let(:sql) { SQL::Builder.new }

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
            it { is_expected_not_to_generate_sql }
          end

          context "missing on the data table" do
            before { @unique_constraints = [] }
            it { yields_error :missing_constraint, columns: [:rep_code] }
            it { is_expected_to_add schema.unique_constraints.first }
          end

          context "defined on another column" do
            before do
              @unique_constraints = [Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_rep_code',
                :reps, :rep_name)]
            end
            it { yields_error :missing_constraint, columns: [:rep_code] }
            it { is_expected_to_drop table.unique_constraints.first }
            it { is_expected_to_add schema.unique_constraints.first }
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
            it { is_expected_not_to_generate_sql }
          end

          context "missing on the data table" do
            before { @unique_constraints = [] }

            it { yields_error :missing_constraint, columns: [:rep_code, :office_code] }
            it { is_expected_to_add schema.unique_constraints.first }
          end

          context "with missing one column in the actual constraint" do
            before do
              @unique_constraints = [Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_rep_code',
                :reps, [:rep_code])]
            end
            it { yields_error :missing_constraint, columns: [:rep_code, :office_code] }
            it { is_expected_to_drop table.unique_constraints.first }
            it { is_expected_to_add schema.unique_constraints.first }
          end

          context "including one extra column" do
            before do
              @unique_constraints = [Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_rep_code',
                :reps, [:rep_code, :office_code, :effective_date])]
            end
            it { yields_error :missing_constraint, columns: [:rep_code, :office_code] }
            it { is_expected_to_drop table.unique_constraints.first }
            it { is_expected_to_add schema.unique_constraints.first }
          end

          context "defined on same columns but in different order" do
            before do
              @unique_constraints = [Gauge::DB::Constraints::UniqueConstraint.new('uc_dbo_reps_12345',
                :reps, [:office_code, :rep_code])]
            end
            it { should_not_yield_errors }
            it { is_expected_not_to_generate_sql }
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
          it { is_expected_to_drop table.unique_constraints.first }
          it { is_expected_to_drop table.unique_constraints.last }
        end
      end

  private

      def dba
        table
      end


      def validate
        validator.do_validate schema, dba, sql
      end


      def is_expected_not_to_generate_sql
        sql.should_receive(:drop_constraint).never
        sql.should_receive(:add_unique_constraint).never
        validate
      end


      def is_expected_to_drop(unique_constraint)
        sql.as_null_object.should_receive(:drop_constraint).once.with(unique_constraint)
        validate
      end


      def is_expected_to_add(unique_constraint)
        sql.should_receive(:add_unique_constraint).once.with(unique_constraint)
        validate
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
