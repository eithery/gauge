# Eithery Lab., 2015.
# Gauge::Validators::ColumnNullabilityValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe ColumnNullabilityValidator do
      let(:validator) { ColumnNullabilityValidator.new }
      let(:database) { double('database_schema', sql_name: 'books_n_records') }
      let(:table_schema) { Schema::DataTableSchema.new(:master_accounts, database: database) }
      let(:schema) { @column_schema }
      let(:sql) { SQL::Builder.new }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        before do
          stub_file_system
          @db_column = double('db_column')
        end

        context "when data column is defined as NOT NULL in metadata" do
          before { @column_schema = Schema::DataColumnSchema.new(:account_number, required: true)
            .in_table table_schema }

          context "and actual data column in DB is nullable" do
            before { stub_db_column_nullability :null }
            it { should_append_error(/Data column '(.*?)account_number(.*?)' must be defined as (.*?)NOT NULL(.*?)/) }
          end

          context "and actual data column in DB is NOT nullable" do
            before { stub_db_column_nullability :not_null }
            it { should_not_yield_errors }
          end
        end


        context "when data column is defined as NULL in metadata" do
          before { @column_schema = Schema::DataColumnSchema.new(:account_number).in_table table_schema }

          context "and actual data column in DB is nullable" do
            before { stub_db_column_nullability :null }
            specify { should_not_yield_errors }
          end

          context "and actual data column in DB is NOT nullable" do
            before { stub_db_column_nullability :not_null }
            it { should_append_error(/Data column '(.*?)account_number(.*?)' must be defined as (.*?)NULL(.*?)/) }
          end
        end


        describe "SQL script generation" do
          before { @column_schema = Schema::DataColumnSchema.new(:account_number, required: true)
            .in_table table_schema }

          context "when validation check is failed" do
            before { stub_db_column_nullability :null }

            it "builds SQL script to alter column" do
              sql.should_receive(:alter_column).with(schema)
              validate
            end
          end

          context "when validation check is passed" do
            before { stub_db_column_nullability :not_null }

            it "does not generate SQL scripts" do
              validator.should_not_receive(:build_sql)
              validate
            end
          end
        end

  private

        def stub_db_column_nullability(nullability)
          allow_null = nullability == :null
          @db_column.stub(:allow_null?).and_return(allow_null)
        end


        def dba
          @db_column
        end


        def validate
          validator.do_validate(schema, dba, sql)
        end
      end
    end
  end
end
