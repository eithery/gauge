# Eithery Lab, 2017
# Gauge::DB::Constraints::ForeignKeyConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      include Constants

      describe ForeignKeyConstraint do

        let(:foreign_key) do
          ForeignKeyConstraint.new(name: 'FK_TRADES_PRIMARY_REPS', table: :trades,
            columns: :rep_code, ref_table: :primary_reps, ref_columns: :code)
        end

        let(:composite_foreign_key) do
          ForeignKeyConstraint.new(name: 'fk_trade_accounts', table: :trades,
            columns: [:account_number, :source_firm_code],
            ref_table: :accounts, ref_columns: [:number, 'Source'])
        end

        subject { foreign_key }

        it { expect(described_class).to be < CompositeConstraint }

        it { should respond_to :ref_table }
        it { should respond_to :ref_table_sql }
        it { should respond_to :ref_columns }
        it { should respond_to :== }


        describe '#ref_table' do
          it "equals to a table name passed in the initializer" do
            TABLES.each do |table_name, actual_table|
              foreign_key = ForeignKeyConstraint.new(name: 'fk_trades_primary_reps', table: :direct_trades,
                columns: :rep_code, ref_table: table_name, ref_columns: :code)
              expect(foreign_key.ref_table).to be actual_table
            end
          end
        end


        describe '#ref_table_sql' do
          REF_TABLES = {
              :direct_trades => 'dbo.direct_trades',
              'ref.source_firms' => 'ref.source_firms',
              :REPS => 'dbo.reps',
              'bnr.Master_Accounts' => 'bnr.master_accounts',
              'dbo.master_account_registration_types' => 'dbo.master_account_registration_types'
          }

          it "returns a full table name for SQL statements" do
            REF_TABLES.each do |table, sql|
              foreign_key = ForeignKeyConstraint.new(name: 'fk_some_name', table: :some_table,
                columns: :some_column, ref_table: table, ref_columns: :some_ref_column)
              expect(foreign_key.ref_table_sql).to eq sql
            end
          end
        end


        describe '#ref_columns' do
          context "for regular foreign keys" do
            it { expect(foreign_key.ref_columns).to have(1).item }
            it { expect(foreign_key.ref_columns).to include(:code) }
          end

          context "for composite foreign keys" do
            it "includes all data columns specified as a composite key in various forms" do
              expect(composite_foreign_key).to have(2).ref_columns
              expect(composite_foreign_key.ref_columns).to include(:number, :source)
            end
          end
        end


        describe '#==' do
          it "returns true for foreign keys defined on the same tables and columns" do
            [
              ForeignKeyConstraint.new(name: 'fk_trades_primary_reps', table: :trades, columns: :rep_code,
                ref_table: :primary_reps, ref_columns: :code),
              ForeignKeyConstraint.new(name: 'fk_trades_primary_reps', table: :dbo_trades, columns: :rep_code,
                ref_table: :dbo_primary_reps, ref_columns: :code),
              ForeignKeyConstraint.new(name: 'fk_trades_primary_reps', table: 'trades', columns: 'rep_code',
                ref_table: 'primary_reps', ref_columns: 'code'),
              ForeignKeyConstraint.new(name: 'fk_trades_primary_reps', table: 'dbo.trades', columns: 'rep_code',
                  ref_table: 'dbo.primary_reps', ref_columns: 'code'),
              ForeignKeyConstraint.new(name: 'fk_trades_primary_reps', table: 'TRADES', columns: 'REP_CODE',
                ref_table: 'DBO.PRIMARY_REPS', ref_columns: 'CODE')
            ]
            .each do |key|
              expect(foreign_key).to_not equal(key)
              expect(foreign_key.==(key)).to be true
              expect(key.==(foreign_key)).to be true
            end
          end

          it "returns true for foreign keys on the same table and columns but having different names" do
            key = ForeignKeyConstraint.new(name: 'fk_trades_12345', table: :trades, columns: :rep_code,
              ref_table: :primary_reps, ref_columns: :code)
            expect(foreign_key.==(key)).to be true
            expect(key.==(foreign_key)).to be true
          end

          it "returns false for different foreign keys" do
            [
              ForeignKeyConstraint.new(name: 'fk_trades_primary_reps', table: :bnr_trades, columns: :rep_code,
                ref_table: :primary_reps, ref_columns: :code),
              ForeignKeyConstraint.new(name: 'fk_trades_primary_reps', table: :trades, columns: :rep_id,
                ref_table: :primary_reps, ref_columns: :code),
              ForeignKeyConstraint.new(name: 'fk_trades_primary_reps', table: :trades, columns: :rep_code,
                ref_table: :reps, ref_columns: :code),
              ForeignKeyConstraint.new(name: 'fk_trades_primary_reps', table: :trades, columns: :rep_code,
                ref_table: :primary_reps, ref_columns: :id)
            ]
            .each do |key|
              expect(foreign_key.==(key)).to be false
              expect(key.==(foreign_key)).to be false
            end
          end

          context "for composite foreign keys" do
            it "returns true for foreign keys on same columns in various order" do
              key = ForeignKeyConstraint.new(name: 'fk_trade_accounts', table: :trades,
                columns: [:source_firm_code, :account_number], ref_table: :accounts,
                ref_columns: ['Source', :number])
              expect(composite_foreign_key.==(key)).to be true
              expect(key.==(composite_foreign_key)).to be true
            end

            it "returns false for different number of columns" do
              key = ForeignKeyConstraint.new(name: 'fk_trade_accounts', table: :trades,
                columns: [:account_number, :source_firm_code, :ordinal], ref_table: :accounts,
                ref_columns: [:number, 'Source', :ordinal])
              expect(composite_foreign_key.==(key)).to be false
              expect(key.==(composite_foreign_key)).to be false
            end
          end
        end
      end
    end
  end
end
