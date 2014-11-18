# Eithery Lab., 2014.
# Gauge::Validators::DataColumnValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DataColumnValidator do
      let(:validator) { DataColumnValidator.new }
      let(:schema) { Schema::DataColumnSchema.new(:account_number) }
      let(:dba) { double('dba', column: @db_column, column_exists?: true) }

      it_behaves_like "any database object validator"
      it { should respond_to :check_before, :check_for }


      describe '#check' do
        before do
          @db_column = double('db_column')
          @db_column.stub(:[]).with(:allow_null).and_return(true)
          @db_column.stub(:[]).with(:db_type).and_return(:nvarchar)
        end

        it "always performs check for missing data column" do
          stub_validator(MissingColumnValidator).should_receive(:validate).with(schema, dba)
          validator.check schema, dba
        end


        context "when data column exists in the table" do
          before { dba.stub(:column_exists?).and_return(true) }

          it "performs data column type validation" do
            stub_validator(ColumnTypeValidator).should_receive(:validate).with(schema, @db_column)
            validator.check schema, dba
          end

          it "performs data column nullability check" do
            stub_validator(ColumnNullabilityValidator).should_receive(:validate).with(schema, @db_column)
            validator.check schema, dba
          end
        end


        context "when missing data column" do
          before { dba.stub(:column_exists?).and_return(false) }

          it "does not perform data column type validation" do
            stub_validator(ColumnTypeValidator).should_not_receive(:validate)
            validator.check schema, dba
          end

          it "does not perform data column nullability check" do
            stub_validator(ColumnNullabilityValidator).should_not_receive(:validate)
            validator.check schema, dba
          end
        end


        context "when no errors found" do
          specify "errors collection remains empty" do
            no_validation_errors { |schema, dba| validator.check(schema, dba) }
          end
        end


        context "when some errors found" do
          before do
            @db_column.stub(:[]).with(:allow_null).and_return(false)
            @db_column.stub(:[]).with(:db_type).and_return(:bigint)
          end

          it "aggregates all errors in the errors collection" do
            validator.check schema, dba
            validator.should have(2).errors
            validator.errors.should include(/but it must be 'nvarchar'/)
            validator.errors.should include(/must be defined as NULL/)
          end
        end
      end
    end
  end
end
