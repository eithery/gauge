# Eithery Lab, 2017
# Gauge::Schema::DatabaseSchema specs

require 'spec_helper'

module Gauge
  module Schema
    include Constants
    include Gauge::Helpers

    describe DatabaseSchema do
      let(:db_path) { File.expand_path(ApplicationHelper.db_home + '/test_db/') }
      let(:database) { DatabaseSchema.new(db_path) }
      let(:empty_db) { DatabaseSchema.new('path/to/db') }

      subject { empty_db }

      it { should respond_to :path }
      it { should respond_to :database_id }
      it { should respond_to :name, :database_name }
      it { should respond_to :object_type }
      it { should respond_to :table_schema, :view_schema }
      it { should respond_to :tables, :views }
      it { should respond_to :table, :view }
      it { should respond_to :has_table?, :has_view? }
      it { should respond_to :to_sym, :to_s }
      it { should respond_to :cleanup_sql_files }


      describe '#initialize' do
        it "accepts a path to the database metadata location" do
          expect(DatabaseSchema.new('/path/to/db').path).to eq '/path/to/db'
        end
      end


      describe '#database_id' do
        it { expect(database.database_id).to be :test_db }
        it { expect(empty_db.database_id).to be :db }
      end


      describe '#to_sym' do
        it "is alias of #database_id" do
          expect(database.to_sym).to be database.database_id
          expect(database.to_sym).to_not be nil
        end
      end


      describe '#to_s' do
        it "returns a database string representation" do
          expect(database.to_s).to eq 'Database test_db'
          expect(empty_db.to_s).to eq 'Database db'
        end
      end


      describe '#path' do
        it "returns the absolute metadata path" do
          expect(database.path).to eq db_path
          expect(empty_db.path).to eq 'path/to/db'
        end
      end


      describe '#name' do
        it "returns a database name" do
          expect(database.name).to eq 'test_db'
          expect(empty_db.name).to eq 'db'
        end
      end


      describe '#database_name' do
        it "is alias of #name" do
          expect(database.database_name).to eq database.name
          expect(database.database_name).to_not be nil
        end
      end


      describe '#object_type' do
        it { expect(database.object_type).to eq 'Database' }
        it { expect(empty_db.object_type).to eq 'Database' }
      end


      describe '#table_schema' do
        it "returns a table schema for the existing table" do
          reps_table = database.tables[:dbo_primary_reps]
          ref_table = database.tables[:ref_contract_types]

          expect(reps_table).to_not be nil
          expect(ref_table).to_not be nil

          REPS_TABLE_NAMES.each do |table_name|
            expect(database.table_schema(table_name)).to be reps_table
            expect(database.table_schema(table_name)).to be_instance_of DataTableSchema
          end
          REF_TABLE_NAMES.each do |table_name|
            expect(database.table_schema(table_name)).to be ref_table
            expect(database.table_schema(table_name)).to be_instance_of DataTableSchema
          end
        end

        it "returns nil when a data table not found" do
          MISSING_TABLE_NAMES.each do |table_name|
            expect(database.table_schema(table_name)).to be nil
          end
        end
      end


      describe '#view_schema' do
        it "returns a view schema for the existing data view" do
          reps_view = database.views[:dbo_primary_reps]
          ref_view = database.views[:ref_contract_types]

          expect(reps_view).to_not be nil
          expect(ref_view).to_not be nil

          REPS_VIEW_NAMES.each do |view_name|
            expect(database.view_schema(view_name)).to be reps_view
            expect(database.view_schema(view_name)).to be_instance_of DataViewSchema
          end
          REF_VIEW_NAMES.each do |view_name|
            expect(database.view_schema(view_name)).to be ref_view
            expect(database.view_schema(view_name)).to be_instance_of DataViewSchema
          end
        end

        it "returns nil when a data view not found" do
          MISSING_VIEW_NAMES.each do |view_name|
            expect(database.view_schema(view_name)).to be nil
          end
        end
      end


      describe '#tables' do
        context "when a database does not have tables" do
          it { expect(empty_db.tables).to be_empty }
        end

        context "when a database contains tables" do
          let(:tables) { [:dbo_accounts, :ref_contract_types, :dbo_customers, :dbo_primary_reps] }

          it "return a collection of data tables metadata" do
            expect(database.tables).to have(4).entries
            tables.each do |table_id|
              expect(database.tables).to include(table_id)
              expect(database.tables[table_id]).to be_instance_of DataTableSchema
            end
          end
        end
      end


      describe '#views' do
        context "when a database does not have views" do
          it { expect(empty_db.views).to be_empty }
        end

        context "when a database contains views" do
          let(:views) { [:dbo_primary_reps, :ref_contract_types] }

          it "returns a collection of data views metadata" do
            expect(database.views).to have(2).entries
            views.each do |view_id|
              expect(database.views).to include(view_id)
              expect(database.views[view_id]).to be_instance_of DataViewSchema
            end
          end
        end
      end


      describe '#table' do
        it "creates a data table schema" do
          table = double('table', table_id: :customers)
          expect(DataTableSchema).to receive(:new).with(hash_including(name: :customers, db: :db)).once.and_return(table)
          empty_db.table :customers
        end

        it "adds a data table schema into the tables collection" do
          expect { empty_db.table :new_table }.to change { empty_db.tables.count }.from(0).to(1)
        end
      end


      describe '#view' do
        it "creates a data view schema" do
          view = double('view', view_id: :accounts)
          expect(DataViewSchema).to receive(:new).with(hash_including(name: :accounts, db: :db)).once.and_return(view)
          empty_db.view :accounts
        end

        it "adds a data view schema into the views collection" do
          expect { empty_db.view :new_view }.to change { empty_db.views.count }.from(0).to(1)
        end
      end


      describe '#has_table?' do
        it "returns true when a data table exists" do
          EXISTING_TABLE_NAMES.each do |table_name|
            expect(database.has_table?(table_name)).to be true
          end
        end

        it "returns false when a data table not found" do
          MISSING_TABLE_NAMES.each do |table_name|
            expect(database.has_table?(table_name)).to be false
          end
        end
      end


      describe '#has_view?' do
        it "returns true when a data view exists" do
          EXISTING_VIEW_NAMES.each do |view_name|
            expect(database.has_view?(view_name)).to be true
          end
        end

        it "returns false when a data view not found" do
          MISSING_VIEW_NAMES.each do |view_name|
            expect(database.has_view?(view_name)).to be false
          end
        end
      end


      describe '#cleanup_sql_files' do
        it "deletes all SQL migration files belong to a database" do
          expect(FileUtils).to receive(:remove_dir).once.with(/\/sql\/test_db/, hash_including(force: true))
          database.cleanup_sql_files
        end
      end
    end
  end
end
