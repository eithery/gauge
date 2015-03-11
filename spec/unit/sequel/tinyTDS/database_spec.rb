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

      it { should respond_to :data_tables }
      it { should respond_to :table_exists?, :column_exists?, :column }
      it { should respond_to :check_constraints, :default_constraints }
      it { should respond_to :primary_keys }


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


      describe '#data_tables' do
      end


      describe '#primary_keys' do
        before do
          Sequel::Dataset.any_instance.stub(:all).and_return([
            { constraint_name: 'pk_account_owner', table_schema: 'dbo', table_name: 'account_owners',
              column_name: 'master_account_id', key_type: '1' },
            { constraint_name: 'pk_account_owner', table_schema: 'dbo', table_name: 'account_owners',
              column_name: 'natural_owner_id', key_type: '1' },
            { constraint_name: 'pk_validation_rules', table_schema: 'vld', table_name: 'validation_rules',
              column_name: 'id', key_type: '2' },
          ])
        end
        subject { database.primary_keys }

        it { should_not be_empty }
        it { should have(2).primary_keys }

        context "where the first element" do
          subject { database.primary_keys.first }

          it { should be_a(Gauge::DB::Constraints::PrimaryKeyConstraint) }
          its(:name) { should == 'pk_account_owner' }
          its(:table) { should == :dbo_account_owners }
          its(:columns) { should include(:master_account_id, :natural_owner_id) }
        end

        context "when the primary key is clustered" do
          specify { database.primary_keys.first.should be_clustered }
        end

        context "when the primary key is not clustered" do
          specify { database.primary_keys.last.should_not be_clustered }
        end
      end


      describe '#check_constraints' do
        before do
          Sequel::Dataset.any_instance.stub(:all).and_return([
            { constraint_name: 'ck_reps_is_active', table_catalog: 'rep_profile', table_schema: 'dbo',
              table_name: 'reps', column_name: 'is_active', check_clause: '([is_active]>= 0) AND [is_active]<=(1))' },
            { constraint_name: 'ck_offices_tax_id', table_catalog: 'rep_profile', table_schema: 'br',
              table_name: 'offices', column_name: 'tax_id', check_clause: '(len[tax_id]=(9))' }
          ])
        end
        subject { database.check_constraints }

        it { should_not be_empty }
        it { should have(2).check_constraints }

        context "where the first element" do
          subject { database.check_constraints.first }

          it { should be_a(Gauge::DB::Constraints::CheckConstraint) }
          its(:name) { should == 'ck_reps_is_active' }
          its(:table) { should == :dbo_reps }
          its(:columns) { should include(:is_active) }
          its(:expression) { should == '([is_active]>= 0) AND [is_active]<=(1))' }
        end
      end


      describe '#default_constraints' do
        before do
          Sequel::Dataset.any_instance.stub(:all).and_return([
            { constraint_name: 'df_risk_tolerance_is_enabled', table_schema: 'ref', table_name: 'risk_tolerance',
              column_name: 'is_enabled', definition: '((1))' },
            { constraint_name: 'df_validation_rules_id', table_schema: 'vld', table_name: 'validation_rules',
              column_name: 'id', definition: '(abs(CONVERT([bigint],CONVERT([varbinary],newid()))))' },
            { constraint_name: 'df_product_updated', table_schema: 'dbo', table_name: 'products',
              column_name: 'updated', definition: '(getdate())' }
          ])
        end
        subject { database.default_constraints }

        it { should_not be_empty }
        it { should have(3).default_constraints }

        context "where the first element" do
          subject { database.default_constraints.first }

          it { should be_a(Gauge::DB::Constraints::DefaultConstraint) }
          its(:name) { should == 'df_risk_tolerance_is_enabled' }
          its(:table) { should == :ref_risk_tolerance }
          its(:column) { should == :is_enabled }
          its(:default_value) { should == '((1))' }
        end
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
