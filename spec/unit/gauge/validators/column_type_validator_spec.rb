# Eithery Lab., 2014.
# Gauge::Validators::ColumnTypeValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe ColumnTypeValidator do
      let(:validator) { ColumnTypeValidator.new }

      it { should respond_to :validate }
      it_behaves_like "any database object validator"

      describe '#validate' do
        before do
          @dba = @db_column = double('db_column')
          @db_column.stub(:[]).with(:db_type).and_return(:nvarchar)
        end

        context "when the actual column type is different from defined in metadata" do
          before { @column_schema = Schema::DataColumnSchema.new(:total_amount, type: :money) }
          it { should_append_error(/Data column '(.*)total_amount(.*)' is 'nvarchar' but it must be 'decimal'/) }
        end

        context "when the actual column type is the same as defined in metadata" do
          before { @column_schema = Schema::DataColumnSchema.new(:total_amount, type: :string) }
          specify { no_validation_errors }
        end
      end
    end
  end
end
