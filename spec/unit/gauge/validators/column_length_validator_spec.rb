# Eithery Lab., 2015.
# Gauge::Validators::ColumnLengthValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe ColumnLengthValidator do
      let(:validator) { ColumnLengthValidator.new }
      let(:database) { double('database_schema', sql_name: 'books_n_records') }
      let(:table_schema) { Schema::DataTableSchema.new(:primary_reps, database: database) }
      let(:schema) { @column_schema }
      let(:sql) { double('sql') }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        before do
          stub_file_system
          @db_column = double('db_column')
        end

        context "for character columns" do
          context "with specified normal length" do
            before { @column_schema = Schema::DataColumnSchema.new(:rep_code, len: 10).in_table table_schema }

            context "in the case of mismatched length" do
              before { stub_column_length 6 }
              it { should_append_error(mismatch_message :rep_code, 6, 10) }
            end

            context "in the case of equal length" do
              before { stub_column_length 10 }
              it { should_not_yield_errors }
            end
          end

          context "with specified MAX length" do
            before { @column_schema = Schema::DataColumnSchema.new(:description, len: :max).in_table table_schema }

            context "in the case of mismatched length" do
              before { stub_column_length 50 }
              it { should_append_error(mismatch_message :description, 50, :max) }
            end

            context "in the case of equal length" do
              before { stub_column_length -1 }
              it { should_not_yield_errors }
            end
          end

          context "with default length" do
            before { @column_schema = Schema::DataColumnSchema.new(:last_name).in_table table_schema }

            context "in the case of mismatched length" do
              before { stub_column_length 50 }
              it { should_append_error(mismatch_message :last_name, 50,
                Schema::DataColumnSchema::DEFAULT_VARCHAR_LENGTH) }
            end

            context "in the case of equal length" do
              before do
                stub_column_length Schema::DataColumnSchema::DEFAULT_VARCHAR_LENGTH
              end
              it { should_not_yield_errors }
            end
          end
        end


        context "for not character column types" do
          before do
            @column_schema = Schema::DataColumnSchema.new(:total_amount, type: :money).in_table table_schema
            stub_column_length nil
          end
          it { should_not_yield_errors }
        end


        context "for ISO code columns (country, US state)" do
          before { @column_schema = Schema::DataColumnSchema.new(:country_code, type: :country).in_table table_schema }

          context "in the case of mismatched length" do
            before { stub_column_length 3 }
            it { should_append_error(mismatch_message :country_code, 3, 2) }
          end

          context "in the case of equal length" do
            before { stub_column_length 2 }
            it { should_not_yield_errors }
          end
        end


        context "for computed columns" do
          before do
            @column_schema = Schema::DataColumnSchema.new(:source_code, computed: { function: :get_source_code })
              .in_table table_schema
            stub_column_length 10
          end
          it { should_not_yield_errors }
        end


        describe "SQL script generation" do
          before { @column_schema = Schema::DataColumnSchema.new(:rep_code, len: 10).in_table table_schema }

          context "when validation check is failed" do
            before { stub_column_length 6 }

            it "builds SQL script to alter column" do
              validator.should_receive(:build_alter_column_sql).with(schema)
              validate
            end

            it "generates correct SQL script" do
              validate
              validator.sql.should ==
                "alter table [dbo].[primary_reps]\n" +
                "alter column [rep_code] nvarchar(10) null;\n" +
                "go\n"
            end
          end

          context "when validation check is passed" do
            before { stub_column_length 10 }

            it "does not generate SQL scripts" do
              validator.should_not_receive(:build_sql)
              validate
            end
          end
        end
      end

  private

      def dba
        @db_column
      end


      def stub_column_length(length)
        @db_column.stub(:length).and_return(length)
      end


      def mismatch_message(column_name, actual_length, defined_length)
        /the length of column '(.*?)#{column_name}(.*?)' is '(.*?)#{actual_length}/i
        /(.*?)', but it must be '(.*?)#{defined_length}(.*?)' chars./i
      end


      def validate
        validator.do_validate(schema, dba, sql)
      end
    end
  end
end
