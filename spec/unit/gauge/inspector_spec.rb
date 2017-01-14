# Eithery Lab, 2017
# Gauge::Inspector specs

require 'spec_helper'

module Gauge
  describe Inspector do
    let(:inspector) do
      inspector = Inspector.new
      inspector.stub(:log)
      Schema::Repo.stub(:new).and_return(repo)
      inspector
    end

    let(:repo) do
      repo = double('repo', validator_for: validator, load: nil)
      allow(repo).to receive(:schema) do |dbo|
        if dbo == 'test_db'
          database_schema
        elsif ['accounts', 'trades'].include? dbo
          table_schema
        end
      end
      repo
    end

    let(:database_schema) do
      db_schema = double('database_schema', object_name: 'Database', sql_name: 'test_db')
      allow(db_schema).to receive(:database_schema).and_return(db_schema)
      db_schema
    end
    let(:table_schema) do
      double('table_schema', object_name: 'Data table', sql_name: 'accounts', database_schema: database_schema)
    end
    let(:validator) { double('validator', check: nil, errors: []) }


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
      before { stub_db_adapter }

      it "displays an error when no arguments specified" do
        expect(inspector).to receive(:error).with(/no database objects specified/i)
        inspector.check []
      end

      it "performs validation for each data object passed as an argument" do
        expect(repo).to receive(:validator_for).with(/accounts|trades/).twice
        inspector.check ['accounts', 'trades']
      end

      it "runs within data adapter session" do
        expect(DB::Adapter).to receive(:session).with(database_schema)
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


      context "for metadata repository context" do
        it "loads metadata for all database objects" do
          expect(Schema::Repo).to receive(:new).with(['db'])
          inspector.check ['test_db']
        end

        it "retrieves a schema containing metadata for the data object passed as an argument" do
          expect(repo).to receive(:schema).with('test_db')
          inspector.check ['test_db']
        end
      end


      context "when at least one argument is a database name" do
        it "performs database structure check using database schema" do
          expect(validator).to receive(:check).with(database_schema, instance_of(Sequel::TinyTDS::Database))
          inspector.check ['test_db']
        end
      end


      context "when at least one argument is a data table name" do
        it "performs data table structure check using data table schema" do
          expect(validator).to receive(:check).with(table_schema, instance_of(Sequel::TinyTDS::Database))
          inspector.check ['accounts']
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
          allow(validator).to receive(:errors) { [] }
        end

        it "displays OK total" do
          expect(inspector.as_null_object).to receive(:ok).with(/ok/i)
          inspector.check ['test_db']
        end
      end


      context "when any validation errors found" do
        before do
          allow(validator).to receive(:errors) { ['error 1', 'error 2'] }
        end

        it "displays the total count of errors" do
          expect(inspector.as_null_object).to receive(:error).with(/total errors found: 2/i)
          inspector.check ['test_db']
        end
      end
    end
  end
end
