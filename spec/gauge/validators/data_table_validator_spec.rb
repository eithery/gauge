# Eithery Lab., 2014.
# Gauge::Validators::DataTableValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DataTableValidator do
      let(:validator) { DataTableValidator.new }
      it_behaves_like "any database object validator"


      describe '#check' do
      end


      describe '#validate' do
        before do
          create_data_column_stubs
          create_data_table_stubs
          create_dba_stubs
          validator.stub(:log) do |message, &block|
            block.call
          end
        end

        it "always performs check for missing data table" do
          stub_validator(MissingTableValidator).should_receive(:validate).with(@table_schema, @dba)
          validator.validate @table_schema, @dba
        end


        context "when data table exists in the database" do
          before { @dba.stub(:table_exists?).and_return(true) }

          it "performs validation for each data column in the table" do
            stub_validator(DataColumnValidator).should_receive(:validate).with(anything, @dba)
              .exactly(@table_schema.columns.count).times
            validator.validate @table_schema, @dba
          end
        end


        context "when missing data table" do
          before { @dba.stub(:table_exists?).and_return(false) }

          it "does not perform data column validation check" do
            stub_validator(DataColumnValidator).should_not_receive(:validate)
            validator.validate @table_schema, @dba
          end
        end


        context "when no errors found" do
          before do
            @db_column.stub(:[]).with(:allow_null)
              .and_return(false, false, true, false, false, true)
            @db_column.stub(:[]).with(:db_type)
              .and_return(:bigint, :nvarchar, :datetime, :bigint, :nvarchar, :datetime)
          end
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
            validator.validate @table_schema, @dba
            validator.should have(3).errors
            validator.errors.should include(/but it must be 'nvarchar'/)
            validator.errors.should include(/must be defined as NULL/)
          end
        end
      end
    end
  end
end
