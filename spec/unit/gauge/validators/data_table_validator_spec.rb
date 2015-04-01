# Eithery Lab., 2015.
# Gauge::Validators::DataTableValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe DataTableValidator do
      let(:validator) { DataTableValidator.new }
      let(:column) do
          db_column = double('db_column')
          db_column.stub(:allow_null?).and_return(true, true, false, true, true, false)
          db_column.stub(:data_type).and_return(:nvarchar, :nvarchar, :bigint, :nvarchar, :nvarchar, :bigint)
          db_column.stub(:length).and_return(Schema::DataColumnSchema::DEFAULT_VARCHAR_LENGTH)
          db_column.stub(:default_value).and_return(nil)
          db_column
      end
      let(:table) { double('table', column_exists?: true, column: column) }
      let(:database) { double('database', sql_name: 'books_n_records', table_exists?: true, table: table) }
      let(:table_schema) do
        Schema::DataTableSchema.new(:master_accounts, database: database) do
          col :account_number
          col :rep_code
        end
      end
      let(:schema) { table_schema }

      it_behaves_like "any database object validator"
      it { should respond_to :check, :do_check_before, :do_check_all }


      describe '#check' do
        before do
          stub_file_system
          Logger.configure(colored: true)
          validator.stub(:log)
        end


        it "creates validator to check missing data table" do
          stub_missing_table_validator = double('missing_table_validator', check: true, errors: [], do_validate: false)
          MissingTableValidator.should_receive(:new).once.and_return(stub_missing_table_validator)
          validator.check table_schema, database
        end


        it "always performs check for missing data table" do
          stub_validator(MissingTableValidator).should_receive(:do_validate).with(table_schema, database)
          validator.check table_schema, database
        end


        context "when data table exists in the database" do
          before { database.stub(:table_exists?).and_return(true) }

          it "creates validator to check primary key contraint" do
            stub_primary_key_validator = double('primary_key_validator', do_validate: false, errors: [])
            PrimaryKeyValidator.should_receive(:new).once.and_return(stub_primary_key_validator)
            validator.check table_schema, database
          end

          it "performs validation check for primary key constraint" do
            stub_validator(PrimaryKeyValidator).should_receive(:do_validate).with(table_schema, database).once
            validator.check table_schema, database
          end

          it "creates validator to check data columns" do
            stub_column_validator = double('data_column_validator', check: true, errors: [])
            DataColumnValidator.should_receive(:new).once.and_return(stub_column_validator)
            validator.check table_schema, database
          end

          it "performs validation check for each column in the data table" do
            stub_validator(DataColumnValidator).should_receive(:check)
              .with(instance_of(Schema::DataColumnSchema), table).exactly(3).times
            validator.check table_schema, database
          end
        end


        context "when missing data table" do
          before { database.stub(:table_exists?).and_return(false) }

          it "does not perform data column validation check" do
            stub_validator(DataColumnValidator).should_not_receive(:check)
            validator.check table_schema, database
          end

          it "does not perform primary key constraint validation check" do
            stub_validator(PrimaryKeyValidator).should_not_receive(:do_validate)
            validator.check table_schema, database
          end
        end


        context "when no errors found" do
          specify "errors collection remains empty" do
            no_validation_errors { |table_schema, database| validator.check(table_schema, database) }
          end

          it "displays successful validation result" do
            allow(validator).to receive(:log).and_call_original
            expect { validator.check(table_schema, database) }
              .to output(/check 'dbo\.master_accounts' data table - (.*?)ok/i).to_stdout
          end
        end


        context "when some errors found" do
          before do
            column.stub(:allow_null?).and_return(false)
            column.stub(:data_type).and_return(:bigint)
          end

          it "displays validation result total with errors" do
            allow(validator).to receive(:log).and_call_original
            expect { validator.check(table_schema, database) }
              .to output(/check '(.*?)dbo\.master_accounts(.*?)' data table - (.*?)failed/i).to_stdout
            expect { validator.check(table_schema, database) }
              .to output(/total 4 errors found/i).to_stdout
          end

          it "aggregates all errors in the errors collection" do
            validator.check table_schema, database
            validator.should have(4).errors
            validator.errors.should include(/but it must be '<b>nvarchar<\/b>'/)
            validator.errors.should include(/must be defined as <b>NULL<\/b>/)
          end
        end

  private

        def dba
          database
        end
      end
    end
  end
end
