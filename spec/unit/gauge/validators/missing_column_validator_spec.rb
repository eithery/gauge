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
      let(:sql) { SQL::Builder.new }

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
            sql.should_not_receive(:build_sql)
            validate
          end
        end


        context "when missing data column" do
          before { dba.stub(:column_exists?).and_return(false) }

          it { should_append_error(/data column '(.*?)account_number(.*)' does (.*?)NOT(.*?) exist/i) }
          it { should be false }

          it "builds SQL script to add missing column" do
            sql.should_receive(:add_column).with(schema)
            validate
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
