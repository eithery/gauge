# Eithery Lab., 2017
# Gauge::Schema::DatabaseSchema specs

require 'spec_helper'

module Gauge
  module Schema
    describe DatabaseSchema do
      let(:db_path) { File.expand_path(ApplicationHelper.db_path + '/test_db/') }
      let(:db_schema) { DatabaseSchema.new(db_path) }
      let(:empty_db_schema) { DatabaseSchema.new('path/to/db') }

      subject { empty_db_schema }

      it { should respond_to :path }
      it { should respond_to :name, :database_name }
      it { should respond_to :object_type }
      it { should respond_to :database_schema }
      it { should respond_to :tables, :views }
      it { should respond_to :define_table, :define_view }
      it { should respond_to :to_sym }
      it { expect(DatabaseSchema).to respond_to :current }


      describe '#initialize' do
        it "accepts a path to the database metadata location" do
          expect(DatabaseSchema.new('/path/to/db').path).to eq '/path/to/db'
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
        it "alias of #name" do
          expect(db_schema.database_name).to eq db_schema.name
        end
      end


      describe '#database_schema' do
        it { expect(db_schema.database_schema).to be db_schema }
      end


      describe '#object_type' do
        it { expect(db_schema.object_type).to eq 'Database' }
      end


      describe '#tables' do
        it "loads metadata for all data tables in the database" do
          expect(db_schema.as_null_object).to receive(:require).with(/test_db\/tables\/(.*)\.rb/i).at_least(4).times
          db_schema.tables
        end

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


      describe '#define_table' do
        it "creates a data table schema" do
          table = double('table', to_sym: :accounts)
          expect(DataTableSchema).to receive(:new).once.and_return(table)
          db_schema.define_table :accounts
        end

        it "adds a data table schema into the tables collection" do
          expect { db_schema.define_table :new_table }.to change { db_schema.tables.count }.from(0).to(1)
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


      describe '#define_view' do
        it "creates a data view schema"
        it "adds a data view schema into the views collection"
      end


      describe '#to_sym' do
        it { expect(db_schema.to_sym).to be :test_db }
      end


      describe '.current' do
        it { expect(DatabaseSchema.current).to be nil }

        it "being initialized during metadata load" do
          expect(DatabaseSchema).to receive(:current=).once.with(empty_db_schema)
          expect(DatabaseSchema).to receive(:current=).once.with(nil)
          empty_db_schema.tables
        end
      end
    end
  end
end
