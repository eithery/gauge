# Eithery Lab., 2014.
# Gauge::Schema::MetadataRepo specs.
require 'spec_helper'

module Gauge
  module Schema
    describe MetadataRepo do
      subject { MetadataRepo }
      let(:database_schema) do
        db_schema = DatabaseSchema.new(:rep_profile, sql_name: 'RepProfile_DB')
        db_schema.tables[:primary_reps] = double('primary_reps')
        db_schema.tables[:ref_]
        db_schema
      end
      before { MetadataRepo.databases[:rep_profile] = database_schema }

      it { should respond_to :databases, :metadata_home }
      it { should respond_to :load, :clear }
      it { should respond_to :database?, :table? }


      describe 'databases' do
        subject { MetadataRepo.databases }

        context "when no database metadata defined" do
          before { MetadataRepo.clear }
          it { should be_empty }
        end

        context "when any database metadata defined" do
          it { should_not be_empty }
          specify { MetadataRepo.databases.should include(:rep_profile) }
        end
      end


      describe 'metadata_home' do
        it "points to the folder containing metadata files" do
          MetadataRepo.metadata_home.should =~ /gauge\/db\z/
        end
      end


      describe 'load' do
        it "loads databases metadata file" do
          MetadataRepo.should_receive(:require).with(/config\/databases\.rb/)
          MetadataRepo.load
        end
      end


      describe 'clear' do
        it "clears metadata repository" do
          MetadataRepo.databases.should_not be_empty
          expect { MetadataRepo.clear }.to change { MetadataRepo.databases.empty? }.from(false).to(true)
          MetadataRepo.databases.should be_empty
        end
      end


      describe 'database?' do
        context "when database with specifid name is defined in the metadata" do
          specify { MetadataRepo.database?(:rep_profile).should be true }
          specify { MetadataRepo.database?('rep_profile').should be true }
          specify { MetadataRepo.database?('RepProfile_DB').should be true }
        end

        context "when database with specified name is not found" do
          specify { MetadataRepo.database?(:account_profile).should be false }
          specify { MetadataRepo.database?('account_profile').should be false }
          specify { MetadataRepo.database?('PackageMe_DB').should be false }
        end
      end


      describe 'table?' do
        context "when data table with specified name is defined in the metadata" do
          specify { MetadataRepo.table?(:primary_reps).should be true }
          specify { MetadataRepo.table?('primary_reps').should be true }
        end

        context "when data table with specified name is not found" do
          specify { MetadataRepo.table?(:master_accounts).should be false }
          specify { MetadataRepo.table?('master_accounts').should be false }
        end
      end
    end
  end
end
