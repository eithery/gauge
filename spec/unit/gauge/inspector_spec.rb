# Eithery Lab., 2017
# Gauge::Inspector specs

require 'spec_helper'

module Gauge
  describe Inspector do
    it { should respond_to :check }


    describe '#initialize' do
      it "configures connection settings" do
        options = { server: 'local\SQLDEV', user: 'admin' }
        expect(DB::Connection).to receive(:configure).with(options).once
        Inspector.new(options)
      end

      it "configures logging infrastructure" do
        expect(Logger).to receive(:configure).with(colored: true).once
        Inspector.new(colored: true)
      end
    end


    describe '#check' do
      let(:inspector) do
        inspector = Inspector.new
        inspector.stub(:log)
        inspector
      end
      let(:db_schema) { Schema::Repo.databases[:test_db] = Schema::DatabaseSchema.new(:test_db) }
      let(:table_schema) do
        table_schema = Schema::DataTableSchema.new(:primary_reps, database: db_schema)
        db_schema.tables[:dbo_primary_reps] = table_schema
      end

      before do
        stub_db_adapter
        Schema::Repo.stub(:load)
        Validators::DatabaseValidator.any_instance.stub(:log)
      end

      it "displays an error when no arguments specified" do
        expect(inspector).to receive(:error).with(/no database objects specified/i)
        inspector.check []
      end

      it "performs validation for each data object passed as an argument" do
        stub_db_schema
        validator = stub_validator Validators::DataTableValidator
        inspector.stub(:validator_for).and_return(validator)

        expect(inspector).to receive(:validator_for).with(/accounts|primary_reps/).twice
        inspector.check ['accounts', 'primary_reps']
      end

      it "runs within data adapter session" do
        expect(DB::Adapter).to receive(:session).with(db_schema)
        inspector.check ['test_db']
      end

      it "displays an initial inspection message" do
        expect(inspector.as_null_object).to receive(:info).with(/database 'test_db' inspecting/i)
        inspector.check ['test_db']
      end

      it "displays a final inspection message" do
        expect(inspector.as_null_object).to receive(:info).with(/database 'test_db' inspected/i)
        inspector.check ['test_db']
      end

      it "raise an error if the validator cannot be determined" do
        stub_db_schema
        expect { inspector.check ['invalid_db_object'] }.to raise_error(Errors::InvalidDatabaseObject,
          /cannot determine validator for 'invalid_db_object'/i)
      end


      context "in metadata repository context" do
        it "loads metadata for all database objects" do
          expect(Schema::Repo).to receive :load
          inspector.check ['test_db']
        end

        it "retrieves a schema containing metadata for the data object passed as an argument" do
          expect(Schema::Repo).to receive(:schema).with('test_db')
          inspector.check ['test_db']
        end
      end


      context "when at least one argument is a database name" do
        it "performs database structure check using DatabaseValidator class" do
          validator = stub_validator Validators::DatabaseValidator
          expect(validator).to receive(:check).with(db_schema, instance_of(Sequel::TinyTDS::Database))
          inspector.check ['test_db']
        end
      end


      context "when at least one argument is a data table name" do
        it "performs data table structure check using DataTableValidator class" do
          validator = stub_validator Validators::DataTableValidator
          expect(validator).to receive(:check).with(table_schema, instance_of(Sequel::TinyTDS::Database))
          inspector.check ['primary_reps']
        end
      end


      context "when metadata for at least one passed DB object is not defined" do
        it "displays the appropriate error message" do
          expect(inspector).to receive(:error).with(/database metadata for '(.*?)unknown_db_object(.*?)' is not found/i)
          inspector.check ['unknown_db_object']
        end
      end


      context "wnen no validation errors found" do
        before do
          validator = double('validator', check: [], errors: [])
          Validators::DatabaseValidator.stub(:new).and_return(validator)
        end

        it "displays OK total" do
          expect(inspector.as_null_object).to receive(:ok).with(/ok/i)
          inspector.check ['test_db']
        end
      end


      context "when any validation errors found" do
        before do
          validator = double('validator', check: [], errors: ['error 1', 'error 2'])
          Validators::DatabaseValidator.stub(:new).and_return(validator)
        end

        it "displays the total count of errors" do
          expect(inspector.as_null_object).to receive(:error).with(/total errors found: 2/i)
          inspector.check ['test_db']
        end
      end
    end


private

    def stub_db_schema
      Schema::Repo.stub(:schema).and_return(table_schema)
    end
  end
end
