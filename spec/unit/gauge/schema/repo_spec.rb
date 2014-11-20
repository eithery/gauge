# Eithery Lab., 2014.
# Gauge::Schema::Repo specs.
require 'spec_helper'

module Gauge
  module Schema
    describe Repo do
      subject { Repo }
      let(:database_schema) do
        db_schema = DatabaseSchema.new(:test_db, sql_name: 'TestDB')
        db_schema.tables[:dbo_primary_reps] = DataTableSchema.new(:primary_reps, database: db_schema)
        db_schema.tables[:ref_contract_types] =
          DataTableSchema.new(:contract_types, sql_schema: :ref, database: db_schema)
        db_schema
      end
      let(:valid_dbo_table_names) { [:primary_reps, 'primary_reps', 'Primary_REPS', '[primary_reps]',
        'dbo.primary_reps', '[dbo].[primary_reps]']}
      let(:valid_ref_table_names) { ['ref.contract_types', '[ref].[contract_types]'] }

      before { Repo.databases[:test_db] = database_schema }

      it { should respond_to :databases, :metadata_home }
      it { should respond_to :load, :clear }
      it { should respond_to :database?, :table? }
      it { should respond_to :schema }
      it { should respond_to :define_table, :define_database }


      describe '.databases' do
        subject { Repo.databases }

        context "when no database metadata defined" do
          before { Repo.clear }
          it { should be_empty }
        end

        context "when any database metadata defined" do
          it { should_not be_empty }
          specify { Repo.databases.should include(:test_db) }
        end
      end


      describe '.metadata_home' do
        it "points to the folder containing metadata files" do
          Repo.metadata_home.should =~ /gauge\/db\z/
        end
      end


      describe '.load' do
        it "loads databases metadata file" do
          Repo.as_null_object.should_receive(:require).with(/config\/databases\.rb/)
          Repo.load
        end

        it "loads all data table metadata for the database" do
          Repo.as_null_object.should_receive(:require).with(/test_db\/tables\/(.*)\.rb/i).at_least(4).times
          Repo.load
        end
      end


      describe '.define_database' do
        before { Repo.clear }

        it "registers database metadata in the repository" do
          expect { Repo.define_database(:blue_troll, sql_name: 'BlueTroll') }
            .to change { Repo.databases.count }.from(0).to(1)
          Repo.databases.should include(:blue_troll)
        end
      end


      describe '.define_table' do
        before do
          @db_schema = DatabaseSchema.new(:blue_troll)
          Repo.stub(:current_db_schema).and_return(@db_schema)
        end

        it "creates data table metadata definition" do
          table_schema = double('participants', to_key: :participants, :database= => @db_schema)
          DataTableSchema.should_receive(:new).with(:participants, hash_including(database: @db_schema))
            .and_return(table_schema)
          Repo.define_table(:participants)
        end

        it "registers data table metadata definition in the database metadata" do
          expect { Repo.define_table(:participants) }
            .to change { @db_schema.tables.count }.from(0).to(1)
          @db_schema.tables.should include(:dbo_participants)
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
          specify { Repo.database?(:test_db).should be true }
          specify { Repo.database?('test_db').should be true }
          specify { Repo.database?('TestDB').should be true }
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
            Repo.schema(:test_db).should == database_schema
            Repo.schema('test_db').should == database_schema
            Repo.schema('TestDB').should == database_schema
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
          specify { Repo.schema('unknown_db_object').should be_nil }
        end
      end
    end
  end
end
