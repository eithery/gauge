# Eithery Lab., 2014.
# Gauge::Inspector specs.
require 'spec_helper'

module Gauge
  describe Inspector do
    let(:inspector) do
      inspector = Inspector.new({}, {})
      inspector.stub(:log)
      inspector
    end
    let(:db_schema) { Schema::Repo.databases[:test_db] = Schema::DatabaseSchema.new(:test_db) }
    let(:table_schema) do
      table_schema = Schema::DataTableSchema.new(:primary_reps, database: db_schema)
      db_schema.tables[:dbo_primary_reps] = table_schema
    end

    subject { Inspector.new({}, {}) }
    it { should respond_to :check }


    describe '#initialize' do
      it "performs configuring of connection settings" do
        global_options = { server: 'local\SQL2012', user: 'admin' }
        DB::Connection.should_receive(:configure).with(hash_including(global_options)).once
        Inspector.new(global_options, {})
      end
    end


    describe '#check' do
      before do
        stub_db_adapter
        Schema::Repo.stub(:load)
      end

      it "displays an error when no arguments specified" do
        inspector.should_receive(:error).with(/no database objects specified/i)
        inspector.check []
      end

      it "performs validation for each data object passed as an argument" do
        inspector.should_receive(:validator_for).with(/test_db|primary_reps/).twice
        inspector.check ['test_db', 'primary_reps']
      end

      it "runs within data adapter session" do
        DB::Adapter.should_receive(:session).with(db_schema)
        inspector.check ['test_db']
      end


      context "in metadata repository context" do
        it "loads metadata for all database objects" do
          Schema::Repo.should_receive :load
          inspector.check ['test_db']
        end

        it "retrieves schema containing metadata for the data object passed as an argument" do
          Schema::Repo.should_receive(:schema).with('test_db')
          inspector.check ['test_db']
        end
      end


      context "when at least one argument is a database name" do
        before { @validator = stub_validator Validators::DatabaseValidator }

        it "performs database structure check using DatabaseValidator class" do
          @validator.should_receive(:check).with(db_schema, instance_of(Sequel::TinyTDS::Database))
          inspector.check ['test_db']
        end
      end


      context "when at least one argument is a data table name" do
        before { @validator = stub_validator Validators::DataTableValidator }

        it "performs data table structure check using DataTableValidator class" do
          @validator.should_receive(:check).with(table_schema, instance_of(Sequel::TinyTDS::Database))
          inspector.check ['primary_reps']
        end
      end


      context "when metadata for at least one passed DB object is not defined" do
        it "displays the appropriate error message" do
          inspector.should_receive(:error).with(/database metadata for 'unknown_db_object' is not found/i)
          inspector.check ['unknown_db_object']
        end
      end
    end
  end
end
