# Eithery Lab., 2015.
# Gauge::Validators::MissingColumnValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe MissingColumnValidator do
      let(:validator) { MissingColumnValidator.new }
      let(:database_schema) { double('database', sql_name: 'books_n_records') }
      let(:table_schema) { Schema::DataTableSchema.new(:accounts, database: database_schema) }
      let(:schema) { Schema::DataColumnSchema.new(:account_number).in_table table_schema }
      let(:dba) { double('dba') }
      let(:sql) { double('sql') }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        subject { validate }
        before { stub_file_system }

        context "when data column exists in the table" do
          before { dba.stub(:column_exists?).and_return(true) }

          it { should_not_yield_errors }
          it { should be true }

          it "does not generate SQL scripts" do
            validator.should_not_receive(:build_sql)
            validate
          end
        end


        context "when missing data column" do
          before { dba.stub(:column_exists?).and_return(false) }

          it { should_append_error(/data column '(.*?)account_number(.*)' does (.*?)NOT(.*?) exist/i) }
          it { should be false }

          it "builds SQL script to add missing column" do
            validator.should_receive(:build_sql).with(:add_column, schema)
            validate
          end

          it "generates correct SQL script" do
            validate
            validator.sql.should ==
              "alter table [dbo].[accounts]\n" +
              "add [account_number] nvarchar(256) null;\n" +
              "go\n"
          end
        end        
      end

  private

      def validate
        validator.do_validate(schema, dba, sql)
      end
    end
  end
end
