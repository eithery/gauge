# Eithery Lab., 2014.
# Gauge::Validators::DataTableValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DataTableValidator do
      let(:validator) { DataTableValidator.new }
      let(:schema) do
        Schema::DataTableSchema.new(:master_accounts) do
          col :account_number
          col :rep_code
        end
      end

      it_behaves_like "any database object validator"
      it { should respond_to :check, :check_before, :check_all }


      describe '#check' do
        before do
          @db_column = double('db_column')
          @db_column.stub(:[]).with(:allow_null).and_return(true, true, false, true, true, false)
          @db_column.stub(:[]).with(:db_type).and_return(:nvarchar, :nvarchar, :bigint, :nvarchar, :nvarchar, :bigint)
          @dba = double('dba', table_exists?: true, column_exists?: true, column: @db_column)
          validator.stub(:log) do |message, &block|
            block.call
          end
        end


        it "creates validator to check missing data table" do
          stub_missing_table_validator = double('missing_table_validator', check: true, errors: [], validate: false)
          MissingTableValidator.should_receive(:new).once.and_return(stub_missing_table_validator)
          validator.check schema, dba
        end


        it "always performs check for missing data table" do
          stub_validator(MissingTableValidator).should_receive(:validate).with(schema, dba)
          validator.check schema, dba
        end


        context "when data table exists in the database" do
          before { dba.stub(:table_exists?).and_return(true) }

          it "creates validator to check data columns" do
            stub_column_validator = double('data_column_validator', check: true, errors: [])
            DataColumnValidator.should_receive(:new).once.and_return(stub_column_validator)
            validator.check schema, dba
          end

          it "performs validation check for each column in the data table" do
            stub_validator(DataColumnValidator).should_receive(:check)
              .with(instance_of(Schema::DataColumnSchema), dba).exactly(3).times
            validator.check schema, dba
          end
        end


        context "when missing data table" do
          before { dba.stub(:table_exists?).and_return(false) }

          it "does not perform data column validation check" do
            stub_validator(DataColumnValidator).should_not_receive(:check)
            validator.check schema, dba
          end
        end


        it "displays log message for data table validation" do
          validator.should_receive(:log).with(/check 'dbo\.master_accounts' data table/i)
          validator.check(schema, dba)
        end


        context "when no errors found" do
          specify "errors collection remains empty" do
            no_validation_errors { |schema, dba| validator.check(schema, dba) }
          end

          it "displays successful validation result" do
            allow(validator).to receive(:log).and_call_original
            expect { validator.check(schema, dba) }
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
            expect { validator.check(schema, dba) }
              .to output(/check 'dbo\.master_accounts' data table - failed/i).to_stdout
            expect { validator.check(schema, dba) }
              .to output(/total 4 errors found/i).to_stdout
          end

          it "aggregates all errors in the errors collection" do
            validator.check schema, dba
            validator.should have(4).errors
            validator.errors.should include(/but it must be 'nvarchar'/)
            validator.errors.should include(/must be defined as NULL/)
          end
        end

  private

        def dba
          @dba
        end
      end
    end
  end
end
