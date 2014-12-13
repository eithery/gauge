# Eithery Lab., 2014.
# Sequel::TynyTDS::Database specs.
require 'spec_helper'

module Sequel
  module TinyTDS
    describe Database do
      let(:database) { Database.new }
      let(:table_schema) { Gauge::Schema::DataTableSchema.new(:accounts, sql_schema: :bnr) }
      let(:column_schema) { Gauge::Schema::DataColumnSchema.new(:account_number).in_table table_schema }
      let(:missing_column_schema) { Gauge::Schema::DataColumnSchema.new(:missing_column).in_table table_schema }

      it { should respond_to :table_exists?, :column_exists?, :column }
      it { should respond_to :check_constraints, :default_constraint }


      describe '#table_exists?' do
        before do
          @table_schema = Gauge::Schema::DataTableSchema.new(:master_accounts, sql_schema: :ref)
          database.stub(:tables).and_return([:master_accounts, :customers])
        end

        it "performs table search in the specified SQL schema scope" do
          database.should_receive(:tables).with(hash_including(schema: :ref)).and_return([:master_accounts])
          database.table_exists? @table_schema
        end

        context "when table does not exist in the database" do
          before { stub_table_local_name 'reps' }
          specify { database.table_exists?(@table_schema).should be false }
        end

        context "when table exists in the database" do
          before { stub_table_local_name 'customers' }
          specify { database.table_exists?(@table_schema).should be true }
        end
      end


      describe '#column_exists?' do
        before { stub_database_schema }

        context "when data column does not exists in the table" do
          specify { database.column_exists?(missing_column_schema).should be false }
        end

        context "when data column exists in the table" do
          specify { database.column_exists?(column_schema).should be true }
        end
      end


      describe '#column' do
        it "retrieves SQL metadata for the data table" do
          database.should_receive(:schema).with('accounts')
            .and_return([[:account_number, double('account_number')]])
          database.column column_schema
        end

        it "returns data column metadata" do
          stub_database_schema
          Gauge::DB::DataColumn.should_receive(:new).once
          database.column column_schema
        end
      end


      describe '#check_constraints' do
        it "returns all check constraints for data table"
      end


      describe '#default_constraint' do
        it "returns default constraint for data column"
      end

  private

      def stub_table_local_name(name)
        @table_schema.stub(:local_name).and_return(name)
      end


      def stub_database_schema
        database.stub(:schema).and_return([
          [:id, double('id')],
          [:account_number, double('account_number')],
          [:created_at, double('created_at')]
        ])
      end
    end
  end
end
