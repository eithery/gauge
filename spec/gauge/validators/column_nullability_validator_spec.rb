# Eithery Lab., 2014.
# Gauge::Validators::ColumnNullabilityValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe ColumnNullabilityValidator do
      let(:validator) { ColumnNullabilityValidator.new }
      subject { validator }

      it { should respond_to :validate }

      describe '#validate' do
        before do
          @errors = []
          validator.stub(:errors).and_return(@errors)
          @column_schema = double('column_schema', column_name: 'account_number')
          @db_column = double('db_column')
        end

        context "when data column is defined as NOT NULL in metadata" do
          before { stub_column_schema_and_return false }

          context "and actual data column in DB is nullable" do
            before { stub_db_column_and_return true }
            it { should_append_error_message 'account_number', 'NOT NULL' }
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
            it { should_append_error_message 'account_number', 'NULL' }
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


      def no_validation_errors_detected
        @errors.should_not_receive(:<<)
        validator.validate(@column_schema, @db_column)
        @errors.should be_empty
      end


      def should_append_error_message(column_name, nullability)
        @errors.should_receive(:<<).with(/Data column '.*#{column_name}.*' must be defined as #{nullability}/)
        validator.validate(@column_schema, @db_column)
      end
    end
  end
end
