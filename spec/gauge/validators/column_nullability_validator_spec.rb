# Eithery Lab., 2014.
# Gauge::Validators::ColumnNullabilityValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe ColumnNullabilityValidator do
      let(:validator) { ColumnNullabilityValidator.new }
      it_behaves_like "any database object validator"

      describe '#validate' do
        before { create_data_column_stubs }

        context "when data column is defined as NOT NULL in metadata" do
          before { stub_column_schema_and_return false }

          context "and actual data column in DB is nullable" do
            before { stub_db_column_and_return true }
            it { should_append_error_message(/Data column '.*account_number.*' must be defined as NOT NULL/) }
          end

          context "and actual data column in DB is NOT nullable" do
            before { stub_db_column_and_return false }
            specify { no_validation_errors_detected }
          end
        end

        context "when data column is defined as NULL in metadata" do
          before { stub_column_schema_and_return true }

          context "and actual data column in DB is nullable" do
            before { stub_db_column_and_return true }
            specify { no_validation_errors_detected }
          end

          context "and actual data column in DB is NOT nullable" do
            before { stub_db_column_and_return false }
            it { should_append_error_message(/Data column '.*account_number.*' must be defined as NULL/) }
          end
        end
      end

private

      def stub_column_schema_and_return(allow_null)
        @column_schema.stub(:allow_null?).and_return(allow_null)
      end


      def stub_db_column_and_return(allow_null)
        @db_column.stub(:[]).with(:allow_null).and_return(allow_null)
      end
    end
  end
end
