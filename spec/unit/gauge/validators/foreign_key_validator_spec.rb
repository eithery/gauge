# Eithery Lab., 2015.
# Gauge::Validators::ForeignKeyValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe ForeignKeyValidator do
      let(:validator) { ForeignKeyValidator.new }
      let(:schema) { @table_schema }
      let(:table) { double('table', foreign_keys: @foreign_keys) }
      let(:sql) { SQL::Builder.new }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        context "a simple (one column) foreign key" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:accounts) do
              col :number, len: 20
              col :ref => 'bnr.reps', required: true
            end
          end

          context "when the same actual foreign key defined" do
            before do
              @foreign_keys = [Gauge::DB::Constraints::ForeignKeyConstraint.new('fk_dbo_accounts_rep_id',
                :accounts, :rep_id, 'bnr.reps', :id)]
            end

            it { should_not_yield_errors }
            it { is_expected_not_to_generate_sql }
          end

          context "when actual foreign key has a different name" do
            before do
              @foreign_keys = [Gauge::DB::Constraints::ForeignKeyConstraint.new('fk_dbo_accounts_12345',
                :accounts, :rep_id, 'bnr.Reps', :id)]
            end

            it { should_not_yield_errors }
            it { is_expected_not_to_generate_sql }
          end

          context "when missing actual foreign key" do
            before { @foreign_keys = [] }
            it { yields_error :missing_foreign_key, columns: [:rep_id], ref_table: :bnr_reps, ref_columns: [:id] }
          end

          context "when actual foreign key defined on another column" do
            before do
              @foreign_keys= [Gauge::DB::Constraints::ForeignKeyConstraint.new('fk_dbo_accounts_rep_id',
                :accounts, :office_id, 'bnr.reps', :id)]
            end

            it { yields_error :missing_foreign_key, columns: [:rep_id], ref_table: :bnr_reps, ref_columns: [:id] }
          end

          context "when actual foreign key references to another table" do
            before do
              @foreign_keys = [Gauge::DB::Constraints::ForeignKeyConstraint.new('fk_dbo_accounts_rep_id',
                :accounts, :rep_id, :reps, :id)]
            end

            it do
              yields_error :ref_table_mismatch, columns: [:rep_id],
                ref_table: :bnr_reps, actual_ref_table: :dbo_reps
            end
          end

          context "when actual foreign key references to another column" do
            before do
              @foreign_keys = [Gauge::DB::Constraints::ForeignKeyConstraint.new('fk_dbo_accounts_rep_id',
                :accounts, :rep_id, 'bnr.reps', :rep_id)]
            end

            it do
              yields_error :ref_columns_mismatch, columns: [:rep_id],
                ref_columns: [:id], actual_ref_columns: [:rep_id]
            end
          end
        end

        context "for composite foreign key" do
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
        sql.should_receive(:add_foreign_key).never
        validate
      end


      def missing_foreign_key_message(options)
        /(.*?)Missing(.*?) #{foreign_key_description(options)}/
      end


      def ref_table_mismatch_message(options)
        columns = options[:columns]
        ref_table = options[:ref_table]
        actual_ref_table = options[:actual_ref_table]
        message = "(.*?)Foreign key(.*?) on \\[#{displayed_names_of(columns)}\\] " +
          "column".pluralize(columns.count) + " references to \\['(.*?)#{actual_ref_table}(.*?)'\\] data table, " +
          "but should be to \\['(.*?)#{ref_table}(.*?)'\\] one."
        /#{message}/
      end


      def ref_columns_mismatch_message(options)
        columns = options[:columns]
        ref_columns = options[:ref_columns]
        actual_ref_columns = options[:actual_ref_columns]
        message = "(.*?)Foreign key(.*?) on \\[#{displayed_names_of(columns)}\\] " +
          "column".pluralize(columns.count) + " references to \\[#{displayed_names_of(actual_ref_columns)}\\] " +
          "column".pluralize(actual_ref_columns.count) +
          ", but should be to \\[#{displayed_names_of(ref_columns)}\\]."
        /#{message}/
      end


      def foreign_key_description(options)
        columns = options[:columns]
        ref_table = options[:ref_table]
        ref_columns = options[:ref_columns]
        "(.*?)foreign key(.*?) on \\[#{displayed_names_of(columns)}\\] " +
        "column".pluralize(columns.count) + " references to \\['(.*?)#{ref_table}(.*?)'\\]\\." +
        "\\[#{displayed_names_of(ref_columns)}\\]"
      end
    end
  end
end
