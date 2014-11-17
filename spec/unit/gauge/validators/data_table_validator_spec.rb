# Eithery Lab., 2014.
# Gauge::Validators::DataTableValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DataTableValidator do
      let(:validator) { DataTableValidator.new }

      it_behaves_like "any database object validator"

      describe '#check' do
        before do
          create_data_column_stubs
          create_data_table_stubs
          create_dba_stubs
          validator.stub(:log) do |message, &block|
            block.call
          end
        end

        it "performs validation check for data table" do
         validator.should_receive(:check).with(@table_schema, @dba)
         validator.check @table_schema, @dba
        end

        it "creates validator to check missing data table" do
          stub_missing_table_validator = double('missing_table_validator', check: true, errors: [], validate: false)
          MissingTableValidator.should_receive(:new).once.and_return(stub_missing_table_validator)
          validator.check @table_schema, @dba
        end
 
        it "always performs check for missing data table" do
          stub_validator(MissingTableValidator).should_receive(:validate).with(@table_schema, @dba)
          validator.check @table_schema, @dba
        end


        context "when data table exists in the database" do
          before { @dba.stub(:table_exists?).and_return(true) }

          it "creates validator to check data columns" do
            stub_column_validator = double('data_column_validator', check: true, errors: [])
            DataColumnValidator.should_receive(:new).once.and_return(stub_column_validator)
            validator.check @table_schema, @dba
          end

          it "performs validation check for each column in the data table" do
            stub_validator(DataColumnValidator).should_receive(:check)
              .with(anything, @dba).exactly(3).times
            validator.check @table_schema, @dba
          end
        end


        context "when missing data table" do
          before { @dba.stub(:table_exists?).and_return(false) }

          it "does not perform data column validation check" do
            stub_validator(DataColumnValidator).should_not_receive(:check)
            validator.check @table_schema, @dba
          end
        end


        it "displays log message for data table validation" do
          validator.should_receive(:log).with(/check 'dbo\.master_accounts' data table/i)
          validator.check(@table_schema, @dba)
        end


        context "when no errors found" do
          before { @schema = @table_schema }

          it_behaves_like "validation passed successfully"

          it "displays successful validation result" do
            allow(validator).to receive(:log).and_call_original
            expect { validator.check(@table_schema, @dba) }
              .to output(/check 'dbo\.master_accounts' data table - ok/i).to_stdout
          end
        end


        context "when some errors found" do
          before do
            @db_column.stub(:[]).with(:allow_null).and_return(false)
            @db_column.stub(:[]).with(:db_type).and_return(:bigint)
          end

          it "displays validation result total with errors" do
            allow(validator).to receive(:log).and_call_original
            expect { validator.check(@table_schema, @dba) }
              .to output(/check 'dbo\.master_accounts' data table - failed/i).to_stdout
            expect { validator.check(@table_schema, @dba) }
              .to output(/total 3 errors found/i).to_stdout
          end

          it "aggregates all errors in the errors collection" do
            validator.check @table_schema, @dba
            validator.should have(3).errors
            validator.errors.should include(/but it must be 'nvarchar'/)
            validator.errors.should include(/must be defined as NULL/)
          end
        end
      end
    end
  end
end
