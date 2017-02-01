# Eithery Lab, 2017
# Sequel::TynyTDS::Database specs

require 'spec_helper'

module Sequel
  module TinyTDS
    describe Database do
      let(:database) { Database.new }

      it { expect(Database).to be < Sequel::Database }

      it { should respond_to :table_exists? }
      it { should respond_to :tables, :table }
      it { should respond_to :views }
      it { should respond_to :primary_keys }
      it { should respond_to :foreign_keys }
      it { should respond_to :unique_constraints }
      it { should respond_to :check_constraints }
      it { should respond_to :default_constraints }
      it { should respond_to :indexes }


      describe '#tables' do
        before { stub_data_tables }

        it { expect(database.tables).to_not be_empty }
        it { expect(database).to have(4).tables }

        context "where the first element" do
          let(:table) { database.tables.first }

          it { expect(table).to be_instance_of Gauge::DB::DataTable }
          it { expect(table.name).to eq 'dbo.accounts' }
          it { expect(table.to_sym).to be :dbo_accounts }
        end

        context "with custom SQL schema" do
          let(:table) { database.tables.last }

          it { expect(table).to be_instance_of Gauge::DB::DataTable }
          it { expect(table.name).to eq 'ref.financial_info' }
          it { expect(table.to_sym).to be :ref_financial_info }
        end
      end


      describe '#views' do
        before { stub_data_views }

        it { expect(database.views).to_not be_empty }
        it { expect(database).to have(2).views }

        context 'where the first element' do
          let(:view) { database.views.first }

          it { expect(view).to be_instance_of Gauge::DB::DataView }
          it { expect(view.name).to eq 'dbo.accounts' }
          it { expect(view.to_sym).to be :dbo_accounts }
          it { expect(view).to_not be_indexed }
          it { expect(view.sql).to eq 'select * from dbo.master_accounts' }
        end

        context 'with custom SQL schema' do
          let(:view) { database.views.last }

          it { expect(view).to be_instance_of Gauge::DB::DataView }
          it { expect(view.name).to eq 'br.direct_trades' }
          it { expect(view.to_sym).to be :br_direct_trades }
          it { expect(view).to be_indexed }
          it { expect(view.sql).to eq 'select trade_id from dbo.direct_trades' }
        end
      end


      describe '#table_exists?' do
        before { stub_data_tables }

        it "returns true when a data table exists" do
          existing_tables.keys.each do |table_name|
            expect(database.table_exists?(table_name)).to be true
          end
        end

        it "returns false when a data table does not exist" do
          missing_tables.each do |table_name|
            expect(database.table_exists?(table_name)).to be false
          end
        end
      end


      describe '#table' do
        before { stub_data_tables }

        context "when a data table exists" do
          it "returns a data table with the specified name" do
            existing_tables.each do |name, table|
              expect(database.table(name)).to be_instance_of Gauge::DB::DataTable
              expect(database.table(name).to_sym).to be table
            end
          end
        end

        it "returns nil when data table does not exist" do
          missing_tables.each do |table_name|
            expect(database.table(table_name)).to be nil
          end
        end
      end


      describe '#primary_keys' do
        before { stub_primary_keys }

        it { expect(database.primary_keys).to_not be_empty }
        it { expect(database).to have(2).primary_keys }

        context "where the first element" do
          let(:primary_key) { database.primary_keys.first }

          it { expect(primary_key).to be_instance_of Gauge::DB::Constraints::PrimaryKeyConstraint }
          it { expect(primary_key.name).to eq 'pk_account_owner' }
          it { expect(primary_key.table).to be :dbo_account_owners }
          it { expect(primary_key.columns).to include(:master_account_id, :natural_owner_id) }
          it { expect(primary_key).to be_composite }
          it { expect(primary_key).to be_clustered }
        end

        context "when a primary key is clustered" do
          it { expect(database.primary_keys.first).to be_clustered }
        end

        context "when a primary key is not clustered" do
          it { expect(database.primary_keys.last).to_not be_clustered }
        end

        context "when a primary key is regular (one column)" do
          it { expect(database.primary_keys.last).to_not be_composite }
        end

        context "when a primary key is composite (multiple columns)" do
          it { expect(database.primary_keys.first).to be_composite }
        end
      end


      describe '#foreign_keys' do
        before { stub_foreign_keys }

        it { expect(database.foreign_keys).not_to be_empty }
        it { expect(database).to have(2).foreign_keys }

        context "where the first element" do
          let(:foreign_key) { database.foreign_keys.first }

          it { expect(foreign_key).to be_instance_of Gauge::DB::Constraints::ForeignKeyConstraint }
          it { expect(foreign_key.name).to eq 'fk_trades_accounts' }
          it { expect(foreign_key.table).to be :dbo_trades }
          it { expect(foreign_key.columns).to include(:account_number, :source_firm_code) }
          it { expect(foreign_key.ref_table).to be :bnr_accounts }
          it { expect(foreign_key.ref_columns).to include(:number, :code) }
          it { expect(foreign_key).to be_composite }
        end

        context "when a foreign key is regular" do
          it { expect(database.foreign_keys.last).to_not be_composite }
        end

        context "when a foreign key is composite" do
          it { expect(database.foreign_keys.first).to be_composite }
        end
      end


      describe '#unique_constraints' do
        before { stub_unique_constraints }

        it { expect(database.unique_constraints).not_to be_empty }
        it { expect(database).to have(2).unique_constraints }

        context "where the first element" do
          let(:unique_constraint) { database.unique_constraints.first }

          it { expect(unique_constraint).to be_an_instance_of Gauge::DB::Constraints::UniqueConstraint }
          it { expect(unique_constraint.name).to eq 'uq_fund_account_number_cusip' }
          it { expect(unique_constraint.table).to be :dbo_fund_accounts }
          it { expect(unique_constraint.columns).to include(:fund_account_number, :cusip) }
          it { expect(unique_constraint).to be_composite }
        end

        context "when an unique constraint is regular (applied to one data column)" do
          it { expect(database.unique_constraints.last).to_not be_composite }
        end

        context "when an unique constraint is composite" do
          it { expect(database.unique_constraints.first).to be_composite }
        end
      end


      describe '#check_constraints' do
        before { stub_check_constraints }

        it { expect(database.check_constraints).to_not be_empty }
        it { expect(database).to have(2).check_constraints }

        context "where the first element" do
          let(:check_constraint) { database.check_constraints.first }

          it { expect(check_constraint).to be_an_instance_of Gauge::DB::Constraints::CheckConstraint }
          it { expect(check_constraint.name).to eq 'ck_reps_is_active' }
          it { expect(check_constraint.table).to be :dbo_reps }
          it { expect(check_constraint.columns).to include(:is_active) }
          it { expect(check_constraint.expression).to eq '([is_active]>= 0) AND [is_active]<=(1))' }
          it { expect(check_constraint).to_not be_composite }
        end
      end


      describe '#default_constraints' do
        before { stub_default_constraints }

        it { expect(database.default_constraints).to_not be_empty }
        it { expect(database).to have(3).default_constraints }

        context "where the first element" do
          let(:default_constraint) { database.default_constraints.first }

          it { expect(default_constraint).to be_an_instance_of Gauge::DB::Constraints::DefaultConstraint }
          it { expect(default_constraint.name).to eq 'df_risk_tolerance_is_enabled' }
          it { expect(default_constraint.table).to be :ref_risk_tolerance }
          it { expect(default_constraint.column).to be :is_enabled }
          it { expect(default_constraint.default_value).to eq '((1))' }
        end
      end


      describe '#indexes' do
        before { stub_indexes }

        it { expect(database.indexes).to_not be_empty }
        it { expect(database).to have(3).indexes }

        context "where the first element" do
          let(:index) { database.indexes.first }

          it { expect(index).to be_an_instance_of Gauge::DB::Index }
          it { expect(index.name).to eq 'idx_fund_account_info' }
          it { expect(index.table).to be :dbo_fund_accounts }
          it { expect(index.columns).to include(:fund_account_number, :cusip) }
          it { expect(index).to be_composite }
          it { expect(index).to be_unique }
          it { expect(index).to be_clustered }
        end

        context "when an index is clustered" do
          it { expect(database.indexes.first).to be_clustered }
        end

        context "when an index is not clustered" do
          it { expect(database.indexes.last).to_not be_clustered }
        end

        context "when an index is unique" do
          it { expect(database.indexes.first).to be_unique }
        end

        context "when an index is not unique" do
          it { expect(database.indexes.last).to_not be_unique }
        end

        context "when an index is regular (contains one column)" do
          it { expect(database.indexes.last).to_not be_composite }
        end

        context "when an index is composite (contains multiple columns)" do
          it { expect(database.indexes.first).to be_composite }
        end
      end


  private

      def stub_data_tables
        Sequel::Dataset.any_instance.stub(:all).and_return([
          { table_name: 'accounts', table_schema: 'dbo' },
          { table_name: 'reps', table_schema: 'bnr' },
          { table_name: 'trades', table_schema: 'dbo' },
          { table_name: 'financial_info', table_schema: 'ref' }
        ])
      end


      def stub_data_views
        Sequel::Dataset.any_instance.stub(:all).and_return([
          { view_name: 'accounts', view_schema: 'dbo', is_indexed: false,
            view_sql: 'select * from dbo.master_accounts' },
          { view_name: 'direct_trades', view_schema: 'br', is_indexed: 1,
            view_sql: 'select trade_id from dbo.direct_trades' }
        ])
      end


      def stub_primary_keys
        Sequel::Dataset.any_instance.stub(:all).and_return([
          { constraint_name: 'pk_account_owner', table_schema: 'dbo', table_name: 'account_owners',
            column_name: 'master_account_id', key_type: 1 },
          { constraint_name: 'PK_ACCOUNT_OWNER', table_schema: 'dbo', table_name: 'Account_Owners',
            column_name: 'natural_owner_id', key_type: 1 },
          { constraint_name: 'pk_validation_rules', table_schema: 'vld', table_name: 'validation_rules',
            column_name: 'id', key_type: 2 }
        ])
      end


      def stub_foreign_keys
        Sequel::Dataset.any_instance.stub(:all).and_return([
          { constraint_name: 'fk_trades_accounts', table_schema: 'dbo', table_name: 'trades',
            column_name: 'account_number', ref_table_schema: 'bnr', ref_table_name: 'accounts',
            ref_column_name: 'number' },
          { constraint_name: 'FK_TRADES_ACCOUNTS', table_schema: 'dbo', table_name: 'Trades',
            column_name: 'source_firm_code', ref_table_schema: 'bnr', ref_table_name: :Accounts,
            ref_column_name: 'code' },
          { constraint_name: 'fk_accounts_risk_tolerance', table_schema: 'dbo', table_name: 'accounts',
            column_name: 'risk_tolerance_id', ref_table_schema: 'ref', rf_table_name: 'risk_tolerance',
            ref_column_name: 'id' }
        ])
      end


      def stub_indexes
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


      def stub_unique_constraints
        Sequel::Dataset.any_instance.stub(:all).and_return([
          { constraint_name: 'uq_fund_account_number_cusip', table_schema: 'dbo', table_name: 'fund_accounts',
            column_name: 'fund_account_number' },
          { constraint_name: 'UQ_FUND_ACCOUNT_NUMBER_CUSIP', table_schema: 'dbo', table_name: 'Fund_Accounts',
            column_name: 'cusip' },
          { constraint_name: 'uq_ref_financial_info_name', table_schema: 'ref', table_name: 'financial_info',
            column_name: 'name' }
        ])
      end


      def stub_check_constraints
        Sequel::Dataset.any_instance.stub(:all).and_return([
          { constraint_name: 'ck_reps_is_active', table_schema: 'dbo',table_name: 'reps',
            column_name: 'is_active', check_clause: '([is_active]>= 0) AND [is_active]<=(1))' },
          { constraint_name: 'ck_offices_tax_id', table_schema: 'br', table_name: 'offices',
            column_name: 'tax_id', check_clause: '(len[tax_id]=(9))' }
        ])
      end


      def stub_default_constraints
        Sequel::Dataset.any_instance.stub(:all).and_return([
          { constraint_name: 'df_risk_tolerance_is_enabled', table_schema: 'ref', table_name: 'risk_tolerance',
            column_name: 'is_enabled', definition: '((1))' },
          { constraint_name: 'df_validation_rules_id', table_schema: 'vld', table_name: 'validation_rules',
            column_name: 'id', definition: '(abs(CONVERT([bigint],CONVERT([varbinary],newid()))))' },
          { constraint_name: 'df_product_updated', table_schema: 'dbo', table_name: 'products',
            column_name: 'updated', definition: '(getdate())' }
        ])
      end


      def existing_tables
        {
          :dbo_accounts         => :dbo_accounts,
          :accounts             => :dbo_accounts,
          :DBO_Accounts         => :dbo_accounts,
          'dbo.accounts'        => :dbo_accounts,
          'ACCOUNTS'            => :dbo_accounts,
          'DBO.Accounts'        => :dbo_accounts,
          :dbo_trades           => :dbo_trades,
          'Trades'              => :dbo_trades,
          :trades               => :dbo_trades,
          '[dbo].[trades]'      => :dbo_trades,
          :bnr_reps             => :bnr_reps,
          :ref_financial_info   => :ref_financial_info,
          'ref.financial_info'  => :ref_financial_info,
          :REF_financial_info   => :ref_financial_info
        }
      end


      def missing_tables
        [:reps, :ref_accounts, :dbo_reps, 'reps', 'dbo.reps', 'ref.accounts']
      end
    end
  end
end
