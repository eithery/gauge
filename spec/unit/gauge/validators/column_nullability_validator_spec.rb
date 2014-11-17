# Eithery Lab., 2014.
# Gauge::Validators::ColumnNullabilityValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe ColumnNullabilityValidator do
      let(:validator) { ColumnNullabilityValidator.new }

      it_behaves_like "any database object validator"

      describe '#validate' do
        before do
          create_data_column_stubs
          @schema = @column_schema
          @dba = @db_column
        end


        context "when data column is defined as NOT NULL in metadata" do
          before { stub_column_schema_nullability :not_null }

          context "and actual data column in DB is nullable" do
            before { stub_db_column_nullability :null }
            it { should_append_error_message(/Data column '.*account_number.*' must be defined as NOT NULL/) }
          end

          context "and actual data column in DB is NOT nullable" do
            before { stub_db_column_nullability :not_null }
            specify { no_validation_errors_detected }
          end
        end

        context "when data column is defined as NULL in metadata" do
          before { stub_column_schema_nullability :null }

          context "and actual data column in DB is nullable" do
            before { stub_db_column_nullability :null }
            specify { no_validation_errors_detected }
          end

          context "and actual data column in DB is NOT nullable" do
            before { stub_db_column_nullability :not_null }
            it { should_append_error_message(/Data column '.*account_number.*' must be defined as NULL/) }
          end
        end
      end
    end
  end
end
