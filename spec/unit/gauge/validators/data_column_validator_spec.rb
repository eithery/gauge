# Eithery Lab., 2015.
# Gauge::Validators::DataColumnValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe DataColumnValidator do
      let(:validator) { DataColumnValidator.new }
      let(:database_schema) { double('database', sql_name: 'books_n_records') }
      let(:table_schema) { Schema::DataTableSchema.new(:accounts, database: database_schema) }
      let(:schema) { Schema::DataColumnSchema.new(:account_number).in_table table_schema }
      let(:dba) { double('dba', column: @db_column, column_exists?: true) }
      let(:sql) { SQL::Builder.new }

      it_behaves_like "any database object validator"
      it { should respond_to :do_check_before, :do_check }


      describe '#check' do
        before do
          stub_file_system
          @db_column = double('db_column')
          @db_column.stub(:allow_null?).and_return(true)
          @db_column.stub(:data_type).and_return(:nvarchar)
          @db_column.stub(:length).and_return(Schema::DataColumnSchema::DEFAULT_VARCHAR_LENGTH)
          @db_column.stub(:default_value).and_return(nil)
        end

        it "always performs check for missing data column" do
          stub_validator(MissingColumnValidator).should_receive(:do_validate).with(schema, dba, sql)
          validate
        end


        context "when data column exists in the table" do
          before { dba.stub(:column_exists?).and_return(true) }

          it "performs data column type validation" do
            stub_validator(ColumnTypeValidator).should_receive(:do_validate).with(schema, @db_column, sql)
            validate
          end

          it "performs data column nullability check" do
            stub_validator(ColumnNullabilityValidator).should_receive(:do_validate).with(schema, @db_column, sql)
            validate
          end
        end


        context "when missing data column" do
          before { dba.stub(:column_exists?).and_return(false) }

          it "does not perform data column type validation" do
            stub_validator(ColumnTypeValidator).should_not_receive(:do_validate)
            validate
          end

          it "does not perform data column nullability check" do
            stub_validator(ColumnNullabilityValidator).should_not_receive(:do_validate)
            validate
          end
        end


        context "when no errors found" do
          specify "errors collection remains empty" do
            no_validation_errors { |schema, dba| validator.check(schema, dba) }
          end
        end


        context "when some errors found" do
          before do
            @db_column.stub(:allow_null?).and_return(false)
            @db_column.stub(:data_type).and_return(:bigint)
          end

          it "aggregates all errors in the errors collection" do
            validate
            validator.should have(2).errors
            validator.errors.should include(/but it must be '<b>nvarchar<\/b>'/)
            validator.errors.should include(/must be defined as <b>NULL<\/b>/)
          end
        end
      end

  private

      def validate
        validator.check schema, dba, sql
      end
    end
  end
end
