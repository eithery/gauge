# Eithery Lab., 2014.
# Gauge::Validators::ColumnTypeValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe ColumnTypeValidator do
      let(:validator) { ColumnTypeValidator.new }
      subject { validator }


      it { should respond_to :validate }


      describe '#validate' do
        before do
          @errors = []
          validator.stub(:errors).and_return(@errors)
          @column_schema = double('column_schema', column_name: 'account_number')
          @db_column = double('db_column')
        end


        context "when the actual column type is different from defined in metadata" do
          before do
            stub_column_schema_for_type :bigint
            stub_db_column_for_type :nvarchar
          end
          it { should_append_error_message(/Data column '.*account_number.*' is 'nvarchar' but it must be 'bigint'/) }
        end


        context "when the actual column type is the same as defined in metadata" do
          before do
            stub_column_schema_for_type :nvarchar
            stub_db_column_for_type :nvarchar
          end
          specify { no_validation_errors_detected }
        end
      end

private

      def stub_column_schema_for_type(column_data_type)
        @column_schema.stub(:data_type).and_return(column_data_type)
      end


      def stub_db_column_for_type(column_data_type)
        @db_column.stub(:[]).with(:db_type).and_return(column_data_type)
      end
    end
  end
end
