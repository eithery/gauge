# Eithery Lab., 2015.
# Gauge::Validators::IndexValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe IndexValidator do
      let(:validator) { IndexValidator.new }
      let(:schema) { @table_schema }
      let(:table) { double('table', indexes: @indexes) }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"

      describe '#validate' do
        context "for regular index (simple, nonclustered, not unique)" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10, index: true
            end
          end

          context "when is exists on the data table" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_12345', :reps, :rep_code)] }
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) }}
          end

          context "when it is missing on the data table" do
            before { @indexes = [] }
            it { should_append_error(/Missing (.*?)index(.*?) on \['(.*?)rep_code(.*?)'\] data column/) }
          end

          context "when it is defined on another column" do
          end

          context "when it is actually unique" do
          end

          context "when it is actually clustered" do
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

          context "when is exists on the data table" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_12345', :reps, [:rep_code, :office_code])] }
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) }}
          end

          context "when it is missing on the data table" do
            before { @indexes = [] }
            it { should_append_error(/Missing (.*?)index(.*?) on \['(.*?)rep_code(.*?)', '(.*?)office_code(.*)'\] data column/) }
          end

          context "when one column is missing in the actual index" do
          end

          context "when it includes one extra column" do
          end

          context "when it is defined on same columns but in different order" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_12345', :reps, [:office_code, :rep_code])] }
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) }}
          end

          context "when it is actually unique" do
          end

          context "when it is actually clustered" do
          end
        end


        context "for unique index" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10, index: { unique: true }
            end
          end

          context "when it exists on the data table" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_12345', :reps, :rep_code, unique: true)] }
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) }}
          end

          context "when it is missing in the data table" do
            before { @indexes = [] }
            it { should_append_error(/Missing (.*?)unique index(.*?) on \['(.*?)rep_code(.*?)'\] data column/) }
          end

          context "when the actual index is not unique" do
          end

          context "when the actual index is clustered" do
          end
        end


        context "for clustered index" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10, index: { clustered: true }
            end
          end

          context "when it exists on the data table" do
            before { @indexes = [Gauge::DB::Index.new('idx_dbo_reps_12345', :reps, :rep_code, clustered: true)] }
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) }}
          end

          context "when it is missing in the data table" do
            before { @indexes = [] }
            it { should_append_error(/Missing (.*?)unique clustered index(.*?) on \['(.*?)rep_code(.*?)'\] data column/) }
          end

          context "when the actual index is not unique" do
          end

          context "when the actual index is unique but nonclustered" do
          end
        end


        context "for redundant indexes" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:reps) do
              col :rep_code, len: 10
              col :office_code, len: 10
            end
          end
        end
      end

  private

      def dba
        table
      end
    end
  end
end
