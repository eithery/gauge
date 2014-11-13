# Eithery Lab., 2014.
# Gauge::Schema::Repo specs.
require 'spec_helper'

module Gauge
  module Schema
    describe Repo do
      subject { Repo }
      let(:database_schema) do
        db_schema = DatabaseSchema.new(:rep_profile, sql_name: 'RepProfile_DB')
        db_schema.tables[:dbo_primary_reps] = double('primary_reps')
        db_schema.tables[:ref_contract_types] = double('contract_types')
        db_schema
      end
      let(:valid_dbo_table_names) { [:primary_reps, 'primary_reps', 'Primary_REPS', '[primary_reps]',
        'dbo.primary_reps', '[dbo].[primary_reps]']}
      let(:valid_ref_table_names) { ['ref.contract_types', '[ref].[contract_types]'] }

      before { Repo.databases[:rep_profile] = database_schema }

      it { should respond_to :databases, :metadata_home }
      it { should respond_to :load, :clear }
      it { should respond_to :database?, :table? }
      it { should respond_to :schema }


      describe '.databases' do
        subject { Repo.databases }

        context "when no database metadata defined" do
          before { Repo.clear }
          it { should be_empty }
        end

        context "when any database metadata defined" do
          it { should_not be_empty }
          specify { Repo.databases.should include(:rep_profile) }
        end
      end


      describe '.metadata_home' do
        it "points to the folder containing metadata files" do
          Repo.metadata_home.should =~ /gauge\/db\z/
        end
      end


      describe '.load' do
        it "loads databases metadata file" do
          Repo.should_receive(:require).with(/config\/databases\.rb/)
          Repo.load
        end
      end


      describe '.clear' do
        it "clears metadata repository" do
          Repo.databases.should_not be_empty
          expect { Repo.clear }.to change { Repo.databases.empty? }.from(false).to(true)
          Repo.databases.should be_empty
        end
      end


      describe '.database?' do
        context "when database with specifid name is defined in the metadata" do
          specify { Repo.database?(:rep_profile).should be true }
          specify { Repo.database?('rep_profile').should be true }
          specify { Repo.database?('RepProfile_DB').should be true }
        end

        context "when database with specified name is not found" do
          specify { Repo.database?(:account_profile).should be false }
          specify { Repo.database?('account_profile').should be false }
          specify { Repo.database?('PackageMe_DB').should be false }
        end
      end


      describe '.table?' do
        context "when data table is defined in metadata and table name specified" do
          context "as symbol" do
            specify { Repo.table?(:primary_reps).should be true }
          end

          context "as string without SQL schema" do
            specify { Repo.table?('primary_reps').should be true }
          end

          context "in different case" do
            specify { Repo.table?('Primary_REPS').should be true }
          end

          context "with square brackets" do
            specify { Repo.table?('[primary_reps]').should be true }
          end

          context "with default SQL schema" do
            specify { Repo.table?('dbo.primary_reps').should be true }
          end

          context "with default SQL schema and square brackets" do
            specify { Repo.table?('[dbo].[primary_reps]').should be true }
          end

          context "with custom SQL schema" do
            specify { Repo.table?('ref.contract_types').should be true }
          end

          context "with custom SQL schema and square brackets" do
            specify { Repo.table?('[ref].[contract_types]').should be true }
          end
        end

        context "when data table with specified name is not found" do
          specify { Repo.table?(:master_accounts).should be false }
          specify { Repo.table?('master_accounts').should be false }
        end
      end


      describe '.schema' do
        context "when passed db object name is a database name" do
          it "returns a valid database schema" do
            Repo.schema(:rep_profile).should == database_schema
            Repo.schema('rep_profile').should == database_schema
            Repo.schema('RepProfile_DB').should == database_schema
          end
        end


        context "when passed db object name is an existing data table name" do
          it "returns a valid table schema" do
            valid_dbo_table_names.each do |table_name|
              Repo.schema(table_name).should == database_schema.tables[:dbo_primary_reps]
            end
            valid_ref_table_names.each do |table_name|
              Repo.schema(table_name).should == database_schema.tables[:ref_contract_types]
            end
          end
        end


        context "when metadata for passed db object name is not found" do
          it "raises an error" do
            expect { Repo.schema 'unknown_db_object' }.to raise_error(/metadata for '(.*)' is not found/i)
          end
        end
      end
    end
  end
end
