# Eithery Lab., 2014.
# Gauge::Validators::ColumnTypeValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe ColumnTypeValidator do
      let(:validator) { ColumnTypeValidator.new }
      let(:database) { double('database', sql_name: 'books_n_records') }
      let(:reps) { Schema::DataTableSchema.new(:reps, database: database) }
      let(:schema) { @column_schema }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        before do
          File.stub(:open)
          Dir.stub(:mkdir)
          @db_column = double('db_column')
          @db_column.stub(:data_type).and_return(:nvarchar)
        end

        context "when the actual column type is different from defined in metadata" do
          before { @column_schema = Schema::DataColumnSchema.new(:total_amount, type: :money).in_table reps }
          it { should_append_error(/data column '(.*?)total_amount(.*?)' is '(.*?)nvarchar(.*?)', but it must be '(.*?)decimal(.*?)'/i) }

          it "builds SQL script to alter column" do
            validator.should_receive(:build_sql).with(:alter_column, schema)
            validate
          end

          it "generates correct SQL script" do
            validate
            validator.sql.should ==
              "alter table [dbo].[reps]\n" +
              "alter column [total_amount] decimal(18,2) null;\n" +
              "go"
          end
        end

        context "when the actual column type is the same as defined in metadata" do
          before { @column_schema = Schema::DataColumnSchema.new(:total_amount, type: :string).in_table reps }
          specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) } }

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
        validator.do_validate(schema, dba)
      end
    end
  end
end
