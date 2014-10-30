# Eithery Lab., 2014.
# Gauge::Repo specs.
require 'spec_helper'

module Gauge
  describe Repo do
    let(:db_name) { 'rep_profile_db' }
    let(:table_name) { 'master_accounts' }
    let(:table_schema) do
      %{
        <table name="master_accounts">
          <columns><col name="number" length="10" required="true"/></columns>
        </table>
      }
    end
    let(:repo) do
      File.stub(:exists?).and_return(true)
      Repo.new
    end


    describe '#validate' do
      context "when the argument is a database name" do
        before do
          repo.stub(:database?).and_return(true)
          @validator = Validators::DatabaseValidator.new
          Validators::DatabaseValidator.stub(:new).and_return(@validator)
        end

        it "performs database structure validation using DatabaseValidator class" do
          @validator.should_receive(:check).with(Schema::DatabaseSchema)
          repo.validate(db_name)
        end
      end


      context "when the argument is a data table name" do
        before do
          File.stub(:open) do |file, mode, &block|
            block.call(table_schema)
          end
          Dir.stub(:[]).and_return([table_name])
          repo.stub(:database_name).and_return(db_name)
          @validator = Validators::DataTableValidator.new
          Validators::DataTableValidator.stub(:new).and_return(@validator)
        end

        it "performs data table structure validation using DataTableValidator class" do
          @validator.should_receive(:check).with(Schema::DataTableSchema)
          repo.validate(table_name)
        end
      end


      context "when metadata for passed DB object is not defined" do
        it "displays the appropriate error message" do
          repo = Repo.new
          repo.should_receive(:error).with(/database metadata for '.*' is not found/i)
          repo.validate('unknown_db_object')
        end
      end
    end
  end
end
