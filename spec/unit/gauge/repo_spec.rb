# Eithery Lab., 2014.
# Gauge::Repo specs.
require 'spec_helper'

module Gauge
  describe Repo do
    let(:repo) { Repo.new }
    let(:table_schema_stub) { double('primary_reps') }

    it { should respond_to :validate }


    describe '#validate' do
      before do
        db_schema = Schema::DatabaseSchema.new(:rep_profile, sql_name: 'RepProfile_DB')
        db_schema.tables[:dbo_primary_reps] = table_schema_stub
        Schema::MetadataRepo.databases[:rep_profile] = db_schema
      end

      context "when the argument is a database name" do
        before { @validator = stub_validator Validators::DatabaseValidator }

        it "performs database structure validation using DatabaseValidator class" do
          @validator.should_receive(:check).with(Schema::DatabaseSchema)
          repo.validate(:rep_profile)
        end
      end


      context "when the argument is a data table name" do
        before { @validator = stub_validator Validators::DataTableValidator }

        it "performs data table structure validation using DataTableValidator class" do
          @validator.should_receive(:check).with(table_schema_stub)
          repo.validate(:primary_reps)
        end
      end


      context "when metadata for passed DB object is not defined" do
        it "displays the appropriate error message" do
          repo.should_receive(:error).with(/database metadata for '.*' is not found/i)
          repo.validate('unknown_db_object')
        end
      end
    end
  end
end
