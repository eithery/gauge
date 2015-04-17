# Eithery Lab., 2015.
# Gauge::Validators::ColumnTypeValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe ColumnTypeValidator do
      let(:validator) { ColumnTypeValidator.new }
      let(:database) { double('database', sql_name: 'books_n_records') }
      let(:reps) { Schema::DataTableSchema.new(:reps, database: database) }
      let(:schema) { @column_schema }
      let(:sql) { SQL::Builder.new }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        before do
          stub_file_system
          @db_column = double('db_column')
          @db_column.stub(:data_type).and_return(:nvarchar)
        end

        context "when the actual column type is different from defined in metadata" do
          before { @column_schema = Schema::DataColumnSchema.new(:total_amount, type: :money).in_table reps }
          it { should_append_error(/data column '(.*?)total_amount(.*?)' is '(.*?)nvarchar(.*?)', but it must be '(.*?)decimal(.*?)'/i) }

          it "builds SQL script to alter column" do
            sql.should_receive(:alter_column).with(schema)
            validate
          end
        end

        context "when the actual column type is the same as defined in metadata" do
          before { @column_schema = Schema::DataColumnSchema.new(:total_amount, type: :string).in_table reps }
          it { should_not_yield_errors }

          it "does not generate SQL script" do
            validator.should_not_receive(:build_sql)
            validate
          end
        end
      end

  private

      def dba
        @db_column
      end


      def validate
        validator.do_validate(schema, dba, sql)
      end
    end
  end
end
