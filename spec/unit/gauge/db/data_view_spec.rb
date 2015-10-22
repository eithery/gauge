# Eithery Lab., 2015.
# Class Gauge::DB::DataView specs.

require 'spec_helper'

module Gauge
  module DB
    describe DataView do
      let(:dbo_name) { 'primary_RePS' }
      let(:view_sql) { 'select number, customer_name, is_active from dbo.master_accounts' }
      let(:view) { DataView.new(dbo_name, view_sql) }
      let(:indexed_view) { DataView.new(dbo_name, view_sql, indexed: true) }
      let(:dbo) { view }
      subject { dbo }

      it_behaves_like "any database object"


      it { should respond_to :indexed?, :with_schemabinding? }
      it { should respond_to :indexes }
      it { should respond_to :to_sym }
      it { should respond_to :sql }
      it { should respond_to :base_tables }


      describe '#indexed?' do
        context 'for regular views' do
          it { should_not be_indexed }
        end

        context 'for indexed views' do
          subject { indexed_view }
          it { should be_indexed }
        end
      end


      describe '#with_schemabinding' do
        context 'for views without schemabinding' do
        end

        context 'for views with schemabinding' do
        end
      end


      describe '#indexes' do
        context 'for regular views' do
        end

        context 'for indexed views' do
        end
      end


      describe '#base_tables' do
      end


      describe '#sql' do
        subject { view.sql }

        it { should_not be_nil }
        it { should == view_sql }
      end


      describe '#to_sym' do
        it "returns the data view name and schema combination converted to a symbol" do
          {
            dbo_name => :dbo_primary_reps,
            'master_Accounts' => :dbo_master_accounts,
            'bnr.tradeS' => :bnr_trades,
            :Accounts => :dbo_accounts
          }.each do |name, expected_symbol|
            DataView.new(name, view_sql).to_sym.should == expected_symbol
          end
        end
      end
    end
  end
end
