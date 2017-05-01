# Eithery Lab, 2017
# Gauge::DB::DataView specs

require 'spec_helper'

module Gauge
  module DB
    describe DataView do
      let(:view_sql) { 'select number, customer_name, is_active from dbo.master_accounts' }
      let(:view) { DataView.new('PRIMARY_REPS', sql: view_sql) }
      let(:indexed_view) { DataView.new('PRIMARY_REPS', sql: view_sql, indexed: true) }

      subject { view }

      it { expect(DataView).to be < DatabaseObject }

      it { should respond_to :indexed?, :with_schemabinding? }
      it { should respond_to :indexes }
      it { should respond_to :to_sym }
      it { should respond_to :sql }
      it { should respond_to :base_tables }


      describe '#indexed?' do
        it "returns false for regular views" do
          expect(view).to_not be_indexed
        end

        it "returns true for indexed views" do
          expect(indexed_view).to be_indexed
        end
      end


      describe '#with_schemabinding' do
        context "for views without schemabinding" do
        end

        context "for views with schemabinding" do
        end
      end


      describe '#indexes' do
        context "for regular views" do
        end

        context "for indexed views" do
        end
      end


      describe '#base_tables' do
      end


      describe '#sql' do
      end


      describe '#to_sym' do
        it "returns a data view name and schema combination converted to a symbol" do
          {
            'PRIMARY_REPS' => :dbo_primary_reps,
            :dbo_primary_reps => :dbo_primary_reps,
            'master_Accounts' => :dbo_master_accounts,
            'bnr.tradeS' => :bnr_trades,
            :Accounts => :dbo_accounts
          }
          .each do |name, expected_symbol|
            expect(DataView.new(name, sql: view_sql).to_sym).to be expected_symbol
          end
        end
      end
    end
  end
end
