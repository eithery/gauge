# Eithery Lab., 2015.
# Class Gauge::DB::DataTable specs.

require 'spec_helper'

module Gauge
  module DB
    describe DataTable do
      let(:database) { Sequel::TinyTDS::Database.new }
      let(:dbo_name) { 'PRIMARY_REPS' }
      let(:dbo) { DataTable.new(dbo_name, database) }
      let(:table) { dbo }
      let(:no_constraints_table) { DataTable.new('no_constraints_table', database) }
      subject { dbo }

      it_behaves_like "any database object"

      it { should respond_to :columns }
      it { should respond_to :column_exists? }
      it { should respond_to :column }
      it { should respond_to :primary_key }
      it { should respond_to :foreign_keys }
      it { should respond_to :unique_constraints }
      it { should respond_to :check_constraints }
      it { should respond_to :default_constraints }
      it { should respond_to :indexes }
      it { should respond_to :to_sym }


      describe '#columns' do
        before { stub_data_table }
        subject { table.columns }

        it { should_not be_empty }
        it { should have(4).columns }

        context "where the last column" do
          subject(:last_column) { table.columns.last }

          it { should be_a(DataColumn) }
          it { expect(last_column.name).to eq 'Is_Active' }
          it { expect(last_column.data_type).to be :tinyint }
          it { expect(last_column.to_sym).to be :is_active }
        end
      end


      describe '#column_exists?' do
        before { stub_data_table }

        context "when the data column exists in the table" do
          it "returns true" do
            [:id, :code, :office_id, :is_active, :OFFICE_ID, 'is_active', 'CODE'].each do |col|
              table.column_exists?(col).should be true
            end
          end
        end

        context "when the data column does not exist in the table" do
          it "returns false" do
            [:rep_id, :rep_code, :is_enabled, 'is_enabled'].each do |col|
              table.column_exists?(col).should be false
            end
          end
        end
      end


      describe '#column' do
        before { stub_data_table }

        context "when the data column exists in the table" do
          it "returns a data column with the specified name" do
            {
              'id' => :id,
              :id => :id,
              :code => :code,
              'CODE' => :code,
              :office_id => :office_id,
              'office_id' => :office_id,
              :OFFICE_ID => :office_id,
              'OFFICE_ID' => :office_id,
              :is_active => :is_active,
              'is_active' => :is_active
            }.each do |name, column|
              table.column(name).should be_a(Gauge::DB::DataColumn)
              table.column(name).to_sym.should == column
            end
          end
        end

        context "when the data column does not exist in the table" do
          it "returns nil" do
            table.column(:rep_code).should be nil
            table.column('rep_code').should be nil
          end
        end
      end


      describe '#primary_key' do
        before do
          database.stub(:primary_keys).and_return([
            Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts, :account_number, clustered: true),
            @pk_reps = Constraints::PrimaryKeyConstraint.new('pk_primary_reps', :primary_reps, :rep_code),
            Constraints::PrimaryKeyConstraint.new('pk_office_types', :office_types, :id, clustered: false)
          ])
        end

        it "selects the primary key belongs to the data table" do
          table.primary_key.should be_equal(@pk_reps)
        end

        context "when the table does not have a primary key" do
          specify { no_constraints_table.primary_key.should be_nil }
        end
      end


      describe '#foreign_keys' do
        before do
          database.stub(:foreign_keys).and_return([
            @fk_rep_code = Constraints::ForeignKeyConstraint.new('fk_accounts_rep_code', :accounts, :rep_code,
              :primary_reps, :code ),
            @fk_office_code = Constraints::ForeignKeyConstraint.new('fk_reps_office_code', :primary_reps,
              :office_code, :offices, :code),
            Constraints::ForeignKeyConstraint.new('fk_trades_account', :trades, [:account_number, :source_code],
              :accounts, [:number, :source])
          ])
        end

        it "selects all foreign keys belong to the data table" do
          table.foreign_keys.should have(1).item
          table.foreign_keys.should include(@fk_office_code)
          table.foreign_keys.should_not include(@fk_rep_code)
        end

        context "when the table does not have foreign keys" do
          specify { no_constraints_table.foreign_keys.should be_empty }
        end
      end


      describe '#unique_constraints' do
        before do
          database.stub(:unique_constraints).and_return([
            @uc_account_number = Constraints::UniqueConstraint.new('uq_account_number', :trades, :account_number),
            @uc_rep_code = Constraints::UniqueConstraint.new('uq_rep_code', :primary_reps, :rep_code),
            @uc_office_code = Constraints::UniqueConstraint.new('uq_office_code', :primary_reps, :office_code)
          ])
        end

        it "selects all unique constraints belong to the data table" do
          table.unique_constraints.should have(2).items
          table.unique_constraints.should include(@uc_office_code, @uc_rep_code)
          table.unique_constraints.should_not include(@uc_account_number)
        end

        context "when the table does not have unique constraints" do
          specify { no_constraints_table.unique_constraints.should be_empty }
        end
      end


      describe '#check_constraints' do
        before do
          database.stub(:check_constraints).and_return([
            @cc_is_enabled = Constraints::CheckConstraint.new('cc_reps_is_enabled', :primary_reps, :is_enabled, 0..1),
            @cc_ordinal = Constraints::CheckConstraint.new('cc_reps_ordinal', :primary_reps, :ordinal,
              'len(ordinal) > 0'),
            @cc_trade_type = Constraints::CheckConstraint.new('cc_trade_type', :trade, :trade_type, 0..5)
          ])
        end

        it "selects all check constraints belong to the data table" do
          table.check_constraints.should have(2).items
          table.check_constraints.should include(@cc_is_enabled, @cc_ordinal)
          table.check_constraints.should_not include(@cc_trade_type)
        end

        context "when the table does not have check constraints" do
          specify { no_constraints_table.check_constraints.should be_empty }
        end
      end


      describe '#default_constraints' do
        before do
          database.stub(:default_constraints).and_return([
            @df_address_state = Constraints::DefaultConstraint.new('df_address_state', :addresses, :us_state, 'US'),
            @df_reps_is_enabled = Constraints::DefaultConstraint.new('df_reps_is_enabled', :primary_reps,
              :is_enabled, true)
          ])
        end

        it "selects all default_constraints belongs to the data table" do
          table.default_constraints.should have(1).item
          table.default_constraints.should include(@df_reps_is_enabled)
          table.default_constraints.should_not include(@df_address_state)
        end

        context "when the table does not have default constraints" do
          specify { no_constraints_table.default_constraints.should be_empty }
        end
      end


      describe '#indexes' do
        before do
          database.stub(:indexes).and_return([
            @idx_account_number = Index.new('idx_account_number', :trades, :account_number, unique: true),
            @idx_rep_office_code = Index.new('idx_rep_office_code', :primary_reps,
              [:rep_code, :office_code], clustered: true, unique: true)
          ])
        end

        it "selects all indexes belong to the data table" do
          table.indexes.should have(1).item
          table.indexes.should include(@idx_rep_office_code)
          table.indexes.should_not include(@idx_account_number)
        end

        context "when the table does not have indexes" do
          specify { no_constraints_table.indexes.should be_empty }
        end
      end


      describe '#to_sym' do
        it "returns the data table name and schema combination converted to symbol" do
          {
            dbo_name => :dbo_primary_reps,
            'master_Accounts' => :dbo_master_accounts,
            'bnr.tradeS' => :bnr_trades,
            :Accounts => :dbo_accounts
          }.each do |name, expected_symbol|
            DataTable.new(name, database).to_sym.should == expected_symbol
          end
        end
      end

  private

      def stub_data_table
        database.stub(:schema).and_return([
          [:id, { db_type: 'bigint', allow_null: false }],
          [:code, { db_type: 'nvarchar', max_chars: 10, allow_null: false }],
          [:office_id, { db_type: 'bigint', allow_null: false }],
          [:Is_Active, { db_type: 'tinyint', default: '((1))', allow_null: false }]
        ])
      end
    end
  end
end
