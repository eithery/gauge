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
      it { should respond_to :data_tables }
      it { should respond_to :primary_keys }
      it { should respond_to :foreign_keys }
      it { should respond_to :unique_constraints }
      it { should respond_to :check_constraints }
      it { should respond_to :default_constraints }
      it { should respond_to :indexes }


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
              column_name: 'master_account_id', key_type: 1 },
            { constraint_name: 'PK_ACCOUNT_OWNER', table_schema: 'dbo', table_name: 'Account_Owners',
              column_name: 'natural_owner_id', key_type: 1 },
            { constraint_name: 'pk_validation_rules', table_schema: 'vld', table_name: 'validation_rules',
              column_name: 'id', key_type: 2 },
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
          it { should be_composite }
          it { should be_clustered }
        end

        context "when the primary key is clustered" do
          specify { database.primary_keys.first.should be_clustered }
        end

        context "when the primary key is not clustered" do
          specify { database.primary_keys.last.should_not be_clustered }
        end

        context "when the primary key is regular (one column)" do
          specify { database.primary_keys.last.should_not be_composite }
        end

        context "when the primary key is composite (multiple columns)" do
          specify { database.primary_keys.first.should be_composite }
        end
      end


      describe '#foreign_keys' do
        before do
          Sequel::Dataset.any_instance.stub(:all).and_return([
            { constraint_name: 'fk_trades_accounts', table_schema: 'dbo', table_name: 'trades',
              column_name: 'account_number', ref_table_schema: 'bnr', ref_table_name: 'accounts',
              ref_column_name: 'number' },
            { constraint_name: 'FK_TRADES_ACCOUNTS', table_schema: 'dbo', table_name: 'Trades',
              column_name: 'source_firm_code', ref_table_schema: 'bnr', ref_table_name: 'source_firms',
              ref_column_name: 'code' },
            { constraint_name: 'fk_accounts_risk_tolerance', table_schema: 'dbo', table_name: 'accounts',
              column_name: 'risk_tolerance_id', ref_table_schema: 'ref', rf_table_name: 'risk_tolerance',
              ref_column_name: 'id' }
          ])
        end
        subject { database.foreign_keys }

        it { should_not be_empty }
        it { should have(2).foreign_keys }

        context "where the first element" do
          subject { database.foreign_keys.first }

          it { should be_a(Gauge::DB::Constraints::ForeignKeyConstraint) }
          its(:name) { should == 'fk_trades_accounts' }
          its(:table) { should == :dbo_trades }
          its(:columns) { should include(:account_number, :source_firm_code) }
          its(:ref_table) { should == :bnr_accounts }
          its(:ref_columns) { should include(:number, :code) }
          it { should be_composite }
        end

        context "when the foreign key is regular" do
          specify { database.foreign_keys.first.should be_composite }
        end

        context "when the foreign key is composite" do
          specify { database.foreign_keys.last.should_not be_composite }
        end
      end


      describe '#unique_constraints' do
        before do
          Sequel::Dataset.any_instance.stub(:all).and_return([
            { constraint_name: 'uq_fund_account_number_cusip', table_schema: 'dbo', table_name: 'fund_accounts',
              column_name: 'fund_account_number' },
            { constraint_name: 'UQ_FUND_ACCOUNT_NUMBER_CUSIP', table_schema: 'dbo', table_name: 'Fund_Accounts',
              column_name: 'cusip' },
            { constraint_name: 'uq_ref_financial_info_name', table_schema: 'ref', table_name: 'financial_info',
              column_name: 'name' }
          ])
        end
        subject { database.unique_constraints }

        it { should_not be_empty }
        it { should have(2).unique_constraints }

        context "where the first element" do
          subject { database.unique_constraints.first }

          it { should be_a(Gauge::DB::Constraints::UniqueConstraint) }
          its(:name) { should == 'uq_fund_account_number_cusip' }
          its(:table) { should == :dbo_fund_accounts }
          its(:columns) { should include(:fund_account_number, :cusip) }
          it { should be_composite }
        end

        context "when the unique constraint is regular (applied to one data column)" do
          specify { database.unique_constraints.first.should be_composite }
        end

        context "when the unique constraint is composite" do
          specify { database.unique_constraints.last.should_not be_composite }
        end
      end


      describe '#check_constraints' do
        before do
          Sequel::Dataset.any_instance.stub(:all).and_return([
            { constraint_name: 'ck_reps_is_active', table_schema: 'dbo',table_name: 'reps',
              column_name: 'is_active', check_clause: '([is_active]>= 0) AND [is_active]<=(1))' },
            { constraint_name: 'ck_offices_tax_id', table_schema: 'br', table_name: 'offices',
              column_name: 'tax_id', check_clause: '(len[tax_id]=(9))' }
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
          it { should_not be_composite }
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


      describe '#indexes' do
        before do
          Sequel::Dataset.any_instance.stub(:all).and_return([
            { constraint_name: 'idx_fund_account_info', table_schema: 'dbo', table_name: 'fund_accounts',
              column_name: 'fund_account_number', is_unique: true, index_type: 1 },
            { constraint_name: 'idx_reps_rep_code', table_schema: 'bnr', table_name: 'reps', column_name: 'rep_code',
              is_unique: true, index_type: 1 },
            { constraint_name: 'IDX_FUND_ACCOUNT_INFO', table_schema: 'dbo', table_name: 'fund_accounts',
              column_name: 'cusip', is_unique: true, index_type: 1 },
            { constraint_name: 'idx_trades_account_number', table_schema: 'bnr', table_name: 'trades',
              column_name: 'account_number', is_unique: false, index_type: 2 }
          ])
        end
        subject { database.indexes }

        it { should_not be_empty }
        it { should have(3).indexes }

        context "where the first element" do
          subject { database.indexes.first }

          it { should be_a(Gauge::DB::Index) }
          its(:name) { should == 'idx_fund_account_info' }
          its(:table) { should == :dbo_fund_accounts }
          its(:columns) { should include(:fund_account_number, :cusip) }
          it { should be_composite }
          it { should be_unique }
          it { should be_clustered }
        end

        context "when the index is clustered" do
          specify { database.indexes.first.should be_clustered }
        end

        context "when the index is not clustered" do
          specify { database.indexes.last.should_not be_clustered }
        end

        context "when the index is unique" do
          specify { database.indexes.first.should be_unique }
        end

        context "when the index is not unique" do
          specify { database.indexes.last.should_not be_unique }
        end

        context "when the index is regular (contains one column)" do
          specify { database.indexes.last.should_not be_composite }
        end

        context "when the index is composite (contains multiple columns)" do
          specify { database.indexes.first.should be_composite }
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
