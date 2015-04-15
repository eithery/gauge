# Eithery Lab., 2015.
# Gauge::Validators::IndexValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe IndexValidator do
      let(:validator) { IndexValidator.new }
      let(:schema) { @table_schema }
      let(:table) { double('table', indexes: @indexes) }
      let(:sql) { SQL::Builder.new }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"

      describe '#validate' do
        context "for regular index (simple, nonclustered, not unique)" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10, index: true
            end
          end

          context "existing on the data table" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_12345', :reps, :rep_code)] }
            it { should_not_yield_errors }
          end

          context "missing on the data table" do
            before { @indexes = [] }
            it { yields_error :missing_index, columns: [:rep_code] }
          end

          context "defined on another column" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps, :rep_name)] }
            it { yields_error :missing_index, columns: [:rep_code] }
          end

          context "which is actually unique" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps, :rep_code, unique: true)] }
            it { yields_error :index_mismatch, columns: [:rep_code], should_be: 'not unique' }
          end

          context "which is actually clustered" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps, :rep_code, clustered: true)] }
            it { yields_error :index_mismatch, columns: [:rep_code], should_be: :nonclustered }
          end
        end


        context "for composite index" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10
              col :office_code, len: 10
              index [:rep_code, :office_code]
            end
          end

          context "existing on the data table" do
            before do
              @indexes = [Gauge::DB::Index.new('idx_dbo_reps_12345', :reps, [:rep_code, :office_code])]
            end
            it { should_not_yield_errors }
          end

          context "missing on the data table" do
            before { @indexes = [] }
            it { yields_error :missing_index, columns: [:rep_code, :office_code] }
          end

          context "with missing one column in the actual index" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps, [:rep_code])] }
            it { yields_error :missing_index, columns: [:rep_code, :office_code] }
          end

          context "including one extra column" do
            before do
              @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps,
                [:rep_code, :office_code, :effective_date])]
            end
            it { yields_error :missing_index, columns: [:rep_code, :office_code] }
          end

          context "defined on same columns but in different order" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_12345', :reps, [:office_code, :rep_code])] }
            it { should_not_yield_errors }
          end

          context "which is actually unique" do
            before do
              @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps,
                [:rep_code, :office_code], unique: true)]
            end
            it { yields_error :index_mismatch, columns: [:rep_code, :office_code], should_be: 'not unique' }
          end

          context "which is actually clustered" do
            before do
              @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps,
                [:rep_code, :office_code], clustered: true)]
            end
            it { yields_error :index_mismatch, columns: [:rep_code, :office_code], should_be: :nonclustered }
          end
        end


        context "for unique index" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10, index: { unique: true }
            end
          end

          context "existing on the data table" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_12345', :reps, :rep_code, unique: true)] }
            it { should_not_yield_errors }
          end

          context "missing on the data table" do
            before { @indexes = [] }
            it { yields_error :missing_index, columns: [:rep_code], unique: true }
          end

          context "which is actually not unique" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps, :rep_code)] }
            it { yields_error :index_mismatch, columns: [:rep_code], should_be: :unique }
          end

          context "which is actually clustered" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps, :rep_code, clustered: true)] }
            it { yields_error :index_mismatch, columns: [:rep_code], should_be: :nonclustered }
          end
        end


        context "for clustered index" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10, index: { clustered: true }
            end
          end

          context "existing on the data table" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_12345', :reps, :rep_code, clustered: true)] }
            it { should_not_yield_errors }
          end

          context "missing on the data table" do
            before { @indexes = [] }
            it { yields_error :missing_index, columns: [:rep_code], clustered: true }
          end

          context "which is actually not unique" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps, :rep_code)] }
            it { yields_error :index_mismatch, columns: [:rep_code], should_be: :clustered }
          end

          context "which is actually unique but nonclustered" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps, :rep_code, unique: true)] }
            it { yields_error :index_mismatch, columns: [:rep_code], should_be: :clustered }
          end
        end


        context "for redundant indexes" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10
              col :office_code, len: 10
            end
            @indexes = [
              Gauge::DB::Index.new('idx_dbo_reps_rep_code', :reps, :rep_code, clustered: true),
              Gauge::DB::Index.new('idx_dbo_reps_office_code', :reps, :office_code)]
          end

          it { yields_error :redundant_index, columns: [:rep_code], clustered: true }
          it { yields_error :redundant_index, columns: [:office_code] }
        end
      end

  private

      def dba
        table
      end


      def missing_index_message(options)
        /Missing #{index_description(options)}/
      end


      def redundant_index_message(options)
        /Redundant #{index_description(options)}/
      end


      def index_mismatch_message(options)
        columns = options[:columns]
        message = "Index on \\[#{displayed_names_of(columns)}\\] data " +
        "column".pluralize(columns.count) +
        " should be (.*?)#{expected_index(options)}(.*?), but actually it is (.*?)#{actual_index(options)}(.*?)"
        /#{message}/
      end


      def index_description(options)
        columns = options[:columns]
        "(.*?)#{kind_of_index(options)}(.*?) on \\[#{displayed_names_of(columns)}\\] data " +
        "column".pluralize(columns.count)
      end


      def kind_of_index(options)
        return "unique clustered index" if options[:clustered]
        return "unique index" if options[:unique]
        "index"
      end


      def expected_index(options)
        options[:should_be].to_s
      end


      def actual_index(options)
        index_type = expected_index(options)
        index_types.each do |expected, actual|
          return actual if index_type == expected
          return expected if index_type == actual
        end
      end


      def index_types
        [
          ['clustered', 'nonclustered'],
          ['unique', 'not unique']
        ]
      end
    end
  end
end
