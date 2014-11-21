# Eithery Lab., 2014.
# Gauge::DatabaseInspector specs.
require 'spec_helper'

module Gauge
  describe DatabaseInspector do
    let(:inspector) { DatabaseInspector.new({}, {}, @args) }
    let(:db_schema) { Schema::Repo.databases[:test_db] = Schema::DatabaseSchema.new(:test_db) }
    let(:table_schema) do
      table_schema = Schema::DataTableSchema.new(:primary_reps, database: db_schema)
      db_schema.tables[:dbo_primary_reps] = table_schema
    end

    before { @args = [] }
    subject { inspector }

    it { should respond_to :check }


    describe '#initialize' do
      it "performs configuring of connection settings" do
        global_options = { server: 'local\SQL2012', user: 'admin' }
        DB::Connection.should_receive(:configure).with(hash_including(global_options)).once
        DatabaseInspector.new(global_options, {}, [])
      end
    end


    describe '#check' do
      before do
        stub_db_adapter
        @args = ['test_db']
      end

      it "displays an error when no arguments specified" do
        @args.clear
        inspector.should_receive(:error).with(/no database objects specified/i)
        inspector.check
      end

      it "performs validation for each data object passed as an argument" do
        @args  << 'primary_reps'
        inspector.should_receive(:validator_for).with(/test_db|primary_reps/).twice
        inspector.check
      end

      it "runs within data adapter session" do
        DB::Adapter.should_receive(:session).with(db_schema)
        inspector.check
      end


      context "in metadata repository context" do
        before { db_schema }

        it "loads metadata for all database objects" do
          Validators::DatabaseValidator.any_instance.stub(:info)
          Schema::Repo.should_receive :load
          inspector.check
        end

        it "retrieves schema containing metadata for the data object passed as an argument" do
          inspector.stub(:error)
          Schema::Repo.should_receive(:schema).with('test_db')
          inspector.check
        end
      end


      context "when at least one argument is a database name" do
        before { @validator = stub_validator Validators::DatabaseValidator }

        it "performs database structure check using DatabaseValidator class" do
          @validator.should_receive(:check).with(db_schema, instance_of(Sequel::TinyTDS::Database))
          inspector.check
        end
      end


      context "when at least one argument is a data table name" do
        before do
          @validator = stub_validator Validators::DataTableValidator
          @args = ['primary_reps']
        end 

        it "performs data table structure check using DataTableValidator class" do
          @validator.should_receive(:check).with(table_schema, instance_of(Sequel::TinyTDS::Database))
          inspector.check
        end
      end


      context "when metadata for at least one passed DB object is not defined" do
        before { @args = ['unknown_db_object'] }

        it "displays the appropriate error message" do
          inspector.should_receive(:error).with(/database metadata for 'unknown_db_object' is not found/i)
          inspector.check
        end
      end
    end
  end
end
