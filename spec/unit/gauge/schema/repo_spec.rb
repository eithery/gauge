# Eithery Lab., 2017
# Gauge::Schema::Repo specs

require 'spec_helper'

module Gauge
  module Schema
    include Constants

    describe Repo do
      let(:repo) { Repo.new('db') }
      let(:abs_db_path) { File.expand_path(ApplicationHelper.root_path + '/spec/support/data') }
      let(:db_schema) { double('db_schema', to_sym: :test_db) }

      it { should respond_to :databases }
      it { should respond_to :clear }
      it { should respond_to :database?, :table? }
      it { should respond_to :schema }
      it { should respond_to :validator_for }


      describe '#initialize' do
        context "when no metadata paths defined" do
          it "creates an empty database collection" do
            expect(Repo.new.databases).to be_empty
          end
        end

        context "wnen a metadata path defined" do
          context "as a relative path" do
            it "creates database metadata schema for each database" do
              expect(DatabaseSchema).to receive(:new).twice.and_return(db_schema)
              Repo.new('db')
            end

            it "populates a database collection" do
              expect(repo.databases).to have(2).entries
              expect(repo.databases).to include(:test_db, :test_db_red)
              repo.databases.values.each do |db|
                expect(db).to be_instance_of DatabaseSchema
              end
            end
          end

          context "as an absolute path" do
            it "creates a database metadata schema for each database" do
              expect(DatabaseSchema).to receive(:new).exactly(3).times.and_return(db_schema)
              Repo.new(abs_db_path)
            end

            it "populates a database collection" do
              repo = Repo.new(abs_db_path)
              expect(repo.databases).to have(3).entries
              expect(repo.databases).to include(:database1, :database2, :database3)
              repo.databases.values.each do |db|
                expect(db).to be_instance_of DatabaseSchema
              end
            end
          end
        end

        context "when multiple metadata paths defined" do
          it "creates a database metadata schema for each database" do
            expect(DatabaseSchema).to receive(:new).exactly(5).times.and_return(db_schema)
            Repo.new('db', abs_db_path)
          end

          it "populates a database collection" do
            repo = Repo.new('db', abs_db_path)
            expect(repo.databases).to have(5).entries
            expect(repo.databases).to include(:test_db, :database3)
            repo.databases.values.each do |db|
              expect(db).to be_instance_of DatabaseSchema
            end
          end
        end
      end


      describe '#databases' do
        context "for newly created repo" do
          it { expect(Repo.new.databases).to_not be nil }
          it { expect(Repo.new.databases).to be_empty }
        end

        context "when no database metadata defined" do
          before { repo.clear }
          it { expect(repo.databases).to be_empty }
        end

        context "when any database metadata defined" do
          it { expect(repo.databases).to_not be_empty }
          it { expect(repo.databases).to have(2).entries }
        end
      end


      describe '#clear' do
        it "clears metadata repository" do
          expect(repo.databases).to_not be_empty
          expect { repo.clear }.to change { repo.databases.empty? }.from(false).to(true)
          expect(repo.databases).to be_empty
        end
      end


      describe '#database?' do
        context "when a database with specified name exists" do
          let(:valid_db_names) { [:test_db, :test_db_red, :TEST_DB, 'test_db', 'TEST_DB', 'Test_Db_Red'] }

          it "returns true for existing DB names" do
            valid_db_names.each do |db_name|
              expect(repo.database?(db_name)).to be true
            end
          end
        end

        context "when a database with specified name is not found" do
          let(:invalid_db_names) { ['testDB', 'testdb', :account_profile, :database1] }

          it "returns false for invalid db names" do
            invalid_db_names.each do |db_name|
              expect(repo.database?(db_name)).to be false
            end
          end
        end
      end


      describe '#table?' do
        it "returns true when a data table exist" do
          EXISTING_TABLE_NAMES.each do |table_name|
            expect(repo.table?(table_name)).to be true
          end
        end

        it "returns false when a data table not found" do
          MISSING_TABLE_NAMES.each do |table_name|
            expect(repo.table?(table_name)).to be false
          end
        end
      end


      describe '#schema' do
        context "when the passed name is a database name" do
          it "returns a valid database schema" do
            db_schema = repo.databases[:test_db]
            expect(repo.schema(:test_db)).to be db_schema
            expect(repo.schema(:test_db)).to be_instance_of DatabaseSchema
            expect(repo.schema('test_db')).to be db_schema
            expect(repo.schema('Test_DB')).to be db_schema
          end
        end

        context "when the passed name is an existing data table name" do
          it "returns a valid table schema" do
            reps_table = repo.databases[:test_db].tables[:dbo_primary_reps]
            ref_table = repo.databases[:test_db].tables[:ref_contract_types]

            REPS_TABLE_NAMES.each do |table_name|
              expect(repo.schema(table_name)).to be reps_table
              expect(repo.schema(table_name)).to be_instance_of DataTableSchema
            end
            REF_TABLE_NAMES.each do |table_name|
              expect(repo.schema(table_name)).to be ref_table
              expect(repo.schema(table_name)).to be_instance_of DataTableSchema
            end
          end
        end

        context "when metadata not found" do
          it { expect(repo.schema('unknown_db_object')).to be nil }
        end
      end


      describe '#validator_for' do
        it "returns a database validator for database metadata" do
          expect(repo.validator_for(:test_db)).to be_instance_of(Validators::DatabaseValidator)
        end

        it "returns a data table validator for data table metadata" do
          expect(repo.validator_for(:primary_reps)).to be_instance_of(Validators::DataTableValidator)
          expect(repo.validator_for(:ref_contract_types)).to be_instance_of(Validators::DataTableValidator)
        end

        it "raise an error if the metadata type cannot be determined" do
          expect { repo.validator_for('invalid_db_object') }.to raise_error(Errors::InvalidDatabaseObject,
            /cannot determine a metadata type for 'invalid_db_object'/i)
        end
      end
    end
  end
end
