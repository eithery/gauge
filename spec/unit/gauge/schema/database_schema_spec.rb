# Eithery Lab, 2017
# Gauge::Schema::DatabaseSchema specs

require 'spec_helper'

module Gauge
  module Schema
    include Constants
    include Gauge::Helpers

    describe DatabaseSchema do
      let(:db_path) { File.expand_path(ApplicationHelper.db_home + '/test_db/') }
      let(:db_schema) { DatabaseSchema.new(db_path) }
      let(:empty_db_schema) { DatabaseSchema.new('path/to/db') }

      subject { empty_db_schema }

      it { should respond_to :path }
      it { should respond_to :database_id }
      it { should respond_to :name, :database_name }
      it { should respond_to :object_type }
      it { should respond_to :table_schema }
      it { should respond_to :tables, :views }
      it { should respond_to :table, :view }
      it { should respond_to :has_table?, :has_view? }
      it { should respond_to :to_sym }
      it { should respond_to :cleanup_sql_files }


      describe '#initialize' do
        it "accepts a path to the database metadata location" do
          expect(DatabaseSchema.new('/path/to/db').path).to eq '/path/to/db'
        end
      end


      describe '#database_id' do
        it { expect(db_schema.database_id).to be :test_db }
      end


      describe '#to_sym' do
        it "always returns database_id" do
          expect(db_schema.to_sym).to be db_schema.database_id
        end
      end


      describe '#path' do
        it "returns the absolute metadata path" do
          expect(db_schema.path).to eq db_path
        end
      end


      describe '#name' do
        it "returns a database name" do
          expect(db_schema.name).to eq 'test_db'
        end
      end


      describe '#database_name' do
        it "is alias of #name" do
          expect(db_schema.database_name).to eq db_schema.name
        end
      end


      describe '#table_schema' do
        it "returns a table schema for existing table" do
          reps_table = db_schema.tables[:dbo_primary_reps]
          ref_table = db_schema.tables[:ref_contract_types]

          REPS_TABLE_NAMES.each do |table_name|
            expect(db_schema.table_schema(table_name)).to be reps_table
            expect(db_schema.table_schema(table_name)).to be_instance_of DataTableSchema
          end
          REF_TABLE_NAMES.each do |table_name|
            expect(db_schema.table_schema(table_name)).to be ref_table
            expect(db_schema.table_schema(table_name)).to be_instance_of DataTableSchema
          end
        end

        it "returns nil when a data table not found" do
          MISSING_TABLE_NAMES.each do |table_name|
            expect(db_schema.table_schema(table_name)).to be nil
          end
        end
      end


      describe '#object_type' do
        it { expect(db_schema.object_type).to eq 'Database' }
      end


      describe '#tables' do
        context "when a database does not have tables" do
          it { expect(empty_db_schema.tables).to be_empty }
        end

        context "when a database contains tables" do
          let(:tables) { [:dbo_accounts, :ref_contract_types, :dbo_customers, :dbo_primary_reps] }

          it "creates the appropriate data table metadata" do
            expect(db_schema.tables).to have(4).entries
            tables.each do |table_key|
              expect(db_schema.tables).to include(table_key)
              expect(db_schema.tables[table_key]).to be_instance_of DataTableSchema
            end
          end
        end
      end


      describe '#table' do
        it "creates a data table schema" do
          table = double('table', table_id: :customers)
          expect(DataTableSchema).to receive(:new).with(hash_including(name: :customers, db: :db)).once.and_return(table)
          empty_db_schema.table :customers
        end

        it "adds a data table schema into the tables collection" do
          expect { empty_db_schema.table :new_table }.to change { empty_db_schema.tables.count }.from(0).to(1)
        end
      end


      describe '#views' do
        it "loads metadata for all data views in the database"

        context "when a database does not have views" do
          it { expect(empty_db_schema.views).to be_empty }
        end

        context "when a database contains views" do
          it "creates the appropriate data view metadata"
        end
      end


      describe '#view' do
        it "creates a data view schema"
        it "adds a data view schema into the views collection"
      end


      describe '#has_table?' do
        it "returns true when a data table exists" do
          EXISTING_TABLE_NAMES.each do |table_name|
            expect(db_schema.has_table?(table_name)).to be true
          end
        end

        it "returns false when a data table not found" do
          MISSING_TABLE_NAMES.each do |table_name|
            expect(db_schema.has_table?(table_name)).to be false
          end
        end
      end


      describe '#has_view?' do
      end


      describe '#cleanup_sql_files' do
        it "deletes all SQL migration files belong to a database" do
          expect(FileUtils).to receive(:remove_dir).once.with(/\/sql\/test_db/, hash_including(force: true))
          db_schema.cleanup_sql_files
        end
      end
    end
  end
end
