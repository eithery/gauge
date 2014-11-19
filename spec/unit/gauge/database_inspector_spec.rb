# Eithery Lab., 2014.
# Gauge::DatabaseInspector specs.
require 'spec_helper'

module Gauge
  describe DatabaseInspector do
    let(:inspector) { DatabaseInspector.new({}, {}, @args) }
    let(:table_schema_stub) { double('primary_reps') }

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
        @db_schema = Schema::DatabaseSchema.new(:rep_profile, sql_name: 'RepProfile_DB')
        @db_schema.tables[:dbo_primary_reps] = table_schema_stub
        Schema::Repo.databases[:rep_profile] = @db_schema
        Schema::Repo.stub(:load)
      end

      it "performs validation for each data object passed as an argument" do
        @args = ['rep_profile', 'books_and_records_db']
        inspector.should_receive(:validator_for).with(/rep_profile|books_and_records_db/).twice
        inspector.check
      end

      it "displays an error when no arguments specified" do
        @args = []
        inspector.should_receive(:error).with(/no database objects specified/i)
        inspector.check
      end


      context "when at least one argument is a database name" do
        before do
          @validator = stub_validator Validators::DatabaseValidator
          @args = ['rep_profile']
        end 

        it "performs database structure check using DatabaseValidator class" do
          @validator.should_receive(:check).with(@db_schema)
          inspector.check
        end
      end


      context "when at least one argument is a data table name" do
        before do
          @validator = stub_validator Validators::DataTableValidator
          @args = ['primary_reps']
        end 

        it "performs data table structure check using DataTableValidator class" do
          @validator.should_receive(:check).with(table_schema_stub)
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


#      describe '#check' do
#        it "runs within data adapter session" do
#          DB::Adapter.should_receive(:session).with('accounts_db_name')
#          validator.check database_schema
#        end
#        it "runs within data adapter session" do
#          DB::Adapter.should_receive(:session).with('rep_profile')
#          validator.check(table_schema)
#        end
#      end
#    end
#  end
