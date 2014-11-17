# Eithery Lab., 2014.
# Gauge::Validators::ColumnNullabilityValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe ColumnNullabilityValidator do
      let(:validator) { ColumnNullabilityValidator.new }

      it { should respond_to :validate }
      it_behaves_like "any database object validator"

      describe '#validate' do
        before { @dba = @db_column = double('db_column') }

        context "when data column is defined as NOT NULL in metadata" do
          before { @column_schema = Schema::DataColumnSchema.new(:account_number, required: true) }

          context "and actual data column in DB is nullable" do
            before { stub_db_column_nullability :null }
            it { should_append_error(/Data column '(.*)account_number(.*)' must be defined as NOT NULL/) }
          end

          context "and actual data column in DB is NOT nullable" do
            before { stub_db_column_nullability :not_null }
            specify { no_validation_errors }
          end
        end


        context "when data column is defined as NULL in metadata" do
          before { @column_schema = Schema::DataColumnSchema.new(:account_number) }

          context "and actual data column in DB is nullable" do
            before { stub_db_column_nullability :null }
            specify { no_validation_errors }
          end

          context "and actual data column in DB is NOT nullable" do
            before { stub_db_column_nullability :not_null }
            it { should_append_error(/Data column '(.*)account_number(.*)' must be defined as NULL/) }
          end
        end

  private

        def stub_db_column_nullability(nullability)
          allow_null = nullability == :null
          @db_column.stub(:[]).with(:allow_null).and_return(allow_null)
        end
      end
    end
  end
end
