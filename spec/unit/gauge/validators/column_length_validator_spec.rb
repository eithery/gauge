# Eithery Lab., 2014.
# Gauge::Validators::ColumnLengthValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe ColumnLengthValidator do
      let(:validator) { ColumnLengthValidator.new }
      let(:schema) { @column_schema }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        before do
          @db_column = double('db_column')
          @db_column.stub(:[]).with(:max_chars).and_return(6)
        end

        context "for character column types" do
          context "when the actual column type length is different from defined in metadata" do
            before { @column_schema = Schema::DataColumnSchema.new(:rep_code, len: 10) }
            it { should_append_error(/the length (.*)rep_code(.*)' is (.*)6(.*)but it must be (.*)10/i) }
          end

          context "when the actual column type length if the same as defined in metadata" do
            before { @column_schema = Schema::DataColumnSchema.new(:rep_code, len: 6) }
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) } }
          end
        end

        context "for not character column types" do
          before { @column_schema = Schema::DataColumnSchema.new(:total_amount, type: :money) }
          specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) } }
        end
      end

  private

      def dba
        @db_column
      end
    end
  end
end
