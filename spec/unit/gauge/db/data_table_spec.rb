# Eithery Lab, 2017
# Gauge::DB::DataTable specs

require 'spec_helper'

module Gauge
  module DB
    include Constraints

    describe DataTable, f: true do

      let(:database) do
        database = double('database')
        database.stub(:schema).and_return([
          [:id, { db_type: 'bigint', allow_null: false }],
          [:code, { db_type: 'nvarchar', max_chars: 10, allow_null: false }],
          [:office_id, { db_type: 'bigint', allow_null: false }],
          [:Is_Active, { db_type: 'tinyint', default: '((1))', allow_null: false }]
        ])
        database
      end

      let(:table) { DataTable.new(name: 'PRIMARY_REPS', db: database) }
      let(:empty_table) { DataTable.new(name: 'empty_table', db: database) }

      subject { table }


      it { expect(DataTable).to be < DatabaseObject }

      it { should respond_to :table_id }
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


      describe '#table_id' do
        it "returns a data table name and schema combination converted to a symbol" do
          {
            'PRIMARY_REPS' => :dbo_primary_reps,
            'master_Accounts' => :dbo_master_accounts,
            'bnr.tradeS' => :bnr_trades,
            :dbo_primary_reps => :dbo_primary_reps,
            :Accounts => :dbo_accounts
          }
          .each do |table_name, expected_table_id|
            expect(DataTable.new(name: table_name, db: database).table_id).to be expected_table_id
          end
        end
      end


      describe '#to_sym' do
        it "is alias of 'table_id'" do
          expect(table.to_sym).to be table.table_id
          expect(empty_table.to_sym).to be empty_table.table_id
          expect(table.to_sym).to_not be nil
          expect(empty_table.to_sym).to_not be nil
          expect(table.to_sym).to be :dbo_primary_reps
        end
      end


      describe '#columns' do
        it { expect(table.columns).to_not be_empty }
        it { expect(table).to have(4).columns }

        context "where the last column" do
          let(:last_column) { table.columns.last }

          it { expect(last_column).to be_a DataColumn }
          it { expect(last_column.name).to eq 'Is_Active' }
          it { expect(last_column.data_type).to be :tinyint }
          it { expect(last_column.column_id).to be :is_active }
        end
      end


      describe '#column_exists?' do
        it "returns true when a data column exists" do
          [:id, :code, :office_id, :is_active, :OFFICE_ID, 'is_active', 'CODE'].each do |col|
            expect(table.column_exists?(col)).to be true
          end
        end

        it "returns false when a data column does not exist" do
          [:rep_id, :rep_code, :is_enabled, 'is_enabled'].each do |col|
            expect(table.column_exists?(col)).to be false
          end
        end
      end


      describe '#column' do
        context "when a data column exists" do
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
            }
            .each do |name, column|
              expect(table.column(name)).to be_a DataColumn
              expect(table.column(name).to_sym).to be column
            end
          end
        end

        context "when a data column does not exist" do
          it "returns nil" do
            expect(table.column(:rep_code)).to be nil
            expect(table.column('rep_code')).to be nil
          end
        end
      end


      describe '#primary_key' do
        let(:primary_keys) {[
          PrimaryKeyConstraint.new(name: 'pk_accounts', table: :accounts, columns: :account_number, clustered: true),
          PrimaryKeyConstraint.new(name: 'pk_primary_reps', table: :primary_reps, columns: :rep_code),
          PrimaryKeyConstraint.new(name: 'pk_office_types', table: :office_types, columns: :id, clustered: false)
        ]}
        before { database.stub(:primary_keys).and_return(primary_keys) }

        it "selects a primary key belongs to the data table" do
          expect(table.primary_key).to be primary_keys[1]
        end

        it "returns nil when the table does not have a primary key" do
          expect(empty_table.primary_key).to be nil
        end
      end


      describe '#foreign_keys' do
        let(:foreign_keys) {[
          ForeignKeyConstraint.new(name: 'fk_accounts_rep_code', table: :accounts, columns: :rep_code,
            ref_table: :primary_reps, ref_columns: :code ),
          ForeignKeyConstraint.new(name: 'fk_reps_office_code', table: :primary_reps, columns: :office_code,
            ref_table: :offices, ref_columns: :code),
          ForeignKeyConstraint.new(name: 'fk_trades_account', table: :trades, columns: [:account_number, :source_code],
            ref_table: :accounts, ref_columns: [:number, :source])
        ]}
        before { database.stub(:foreign_keys).and_return(foreign_keys) }

        it "selects all foreign keys belong to the data table" do
          expect(table.foreign_keys).to have(1).item
          expect(table.foreign_keys).to include(foreign_keys[1])
        end

        it "returns an empty collection when the table does not have foreign keys" do
          expect(empty_table.foreign_keys).to be_empty
        end
      end


      describe '#unique_constraints' do
        let(:unique_constraints) {[
          UniqueConstraint.new(name: 'uq_account_number', table: :trades, columns: :account_number),
          UniqueConstraint.new(name: 'uq_rep_code', table: :primary_reps, columns: :rep_code),
          UniqueConstraint.new(name: 'uq_office_code', table: :primary_reps, columns: :office_code)
        ]}
        before { database.stub(:unique_constraints).and_return(unique_constraints)}

        it "selects all unique constraints belong to the data table" do
          expect(table.unique_constraints).to have(2).items
          expect(table.unique_constraints).to include(unique_constraints[1], unique_constraints[2])
        end

        it "returns an empty collection when the table does not have unique constraints" do
          expect(empty_table.unique_constraints).to be_empty
        end
      end


      describe '#check_constraints' do
        let(:check_constraints) {[
          CheckConstraint.new(name: 'cc_reps_is_enabled', table: :primary_reps, columns: :is_enabled, check: 0..1),
          CheckConstraint.new(name: 'cc_reps_ordinal', table: :primary_reps, columns: :ordinal,
            check: 'len(ordinal) > 0'),
          CheckConstraint.new(name: 'cc_trade_type', table: :trade, columns: :trade_type, check: 0..5)
        ]}
        before { database.stub(:check_constraints).and_return(check_constraints) }

        it "selects all check constraints belong to the data table" do
          expect(table.check_constraints).to have(2).items
          expect(table.check_constraints).to include(check_constraints[0], check_constraints[1])
        end

        it "returns an empty collection when the table does not have check constraints" do
          expect(empty_table.check_constraints).to be_empty
        end
      end


      describe '#default_constraints' do
        let(:default_constraints) {[
          DefaultConstraint.new(name: 'df_address_state', table: :addresses, column: :us_state, default_value: 'US'),
          DefaultConstraint.new(name: 'df_reps_is_enabled', table: :primary_reps, column: :is_enabled,
            default_value: true)
        ]}
        before { database.stub(:default_constraints).and_return(default_constraints) }

        it "selects all default_constraints belongs to the data table" do
          expect(table.default_constraints).to have(1).item
          expect(table.default_constraints).to include(default_constraints[1])
        end

        it "returns and empty collection when the table does not have default constraints" do
          expect(empty_table.default_constraints).to be_empty
        end
      end


      describe '#indexes' do
        let(:indexes) {[
          Index.new(name: 'idx_account_number', table: :trades, columns: :account_number, unique: true),
          Index.new(name: 'idx_rep_office_code', table: :primary_reps, columns: [:rep_code, :office_code],
            clustered: true, unique: true)
        ]}
        before { database.stub(:indexes).and_return(indexes) }

        it "selects all indexes belong to the data table" do
          expect(table.indexes).to have(1).item
          expect(table.indexes).to include(indexes[1])
        end

        it "returns an empty collection when the table does not have indexes" do
          expect(empty_table.indexes).to be_empty
        end
      end
    end
  end
end
