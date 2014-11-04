# Eithery Lab., 2014.
# Gauge::Validators::DataColumnValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DataColumnValidator do
      let(:validator) { DataColumnValidator.new }
      it_behaves_like "any database object validator"

      describe '#validate' do
        before do
          create_data_column_stubs
          stub_column_schema_nullability :null
          stub_column_schema_type :nvarchar
          stub_db_column_nullability :null
          stub_db_column_type :nvarchar
          create_dba_stubs
        end

        it "always performs check for missing data column" do
          stub_validator(MissingColumnValidator).should_receive(:validate).with(@column_schema, @dba)
          validator.validate @column_schema, @dba
        end


        context "when data column exists in the table" do
          before { @dba.stub(:column_exists?).and_return(true) }

          it "performs data column type validation" do
            stub_validator(ColumnTypeValidator).should_receive(:validate).with(@column_schema, @db_column)
            validator.validate @column_schema, @dba
          end

          it "performs data column nullability check" do
            stub_validator(ColumnNullabilityValidator).should_receive(:validate).with(@column_schema, @db_column)
            validator.validate @column_schema, @dba
          end
        end


        context "when missing data column" do
          before { @dba.stub(:column_exists?).and_return(false) }

          it "does not perform data column type validation" do
            stub_validator(ColumnTypeValidator).should_not_receive(:validate)
            validator.validate @column_schema, @dba
          end

          it "does not perform data column nullability check" do
            stub_validator(ColumnNullabilityValidator).should_not_receive(:validate)
            validator.validate @column_schema, @dba
          end
        end


        context "when no errors found" do
          specify "errors collection remains empty" do
            no_validation_errors_detected
          end
        end


        context "when some errors found" do
          before do
            @db_column.stub(:[]).with(:allow_null).and_return(false)
            @db_column.stub(:[]).with(:db_type).and_return(:bigint)
          end

          it "aggregates all errors in the errors collection" do
            validator.validate @column_schema, @dba
            validator.should have(2).errors
            validator.errors.should include(/but it must be 'nvarchar'/)
            validator.errors.should include(/must be defined as NULL/)
          end
        end
      end
    end
  end
end
