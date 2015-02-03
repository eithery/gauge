# Eithery Lab., 2015.
# Class Gauge::DB::ForeignKey specs.

require 'spec_helper'

module Gauge
  module DB
    describe ForeignKey do
      let(:foreign_key) { ForeignKey.new('FK_Trade_Primary_Reps', :direct_trades, :rep_code, :primary_reps, :code) }
      let(:composite_foreign_key) do
        ForeignKey.new('fk_trade_accounts', :direct_trades, [:Account_Number, :source_firm_code],
          :accounts, [:number, 'Source'])
      end
      subject { foreign_key }

      it { should respond_to :name }
      it { should respond_to :table, :ref_table }
      it { should respond_to :columns, :ref_columns }


      describe '#name' do
        it "equals to the key name in downcase passed in the initializer" do
          foreign_key.name.should == 'fk_trade_primary_reps'
        end
      end


      describe '#table' do
        it "equals to the table name passed in the initializer in various forms" do
          tables = {
            :dbo_direct_trades => :dbo_direct_trades,
            'dbo.DIRECT_Trades' => :dbo_direct_trades,
            'direct_trades' => :direct_trades,
            :br_CUSTOMER_Financial_Info => :br_customer_financial_info,
            'br.customer_financial_INFO' => :br_customer_financial_info
          }
          .each do |table_name, actual_table|
            foreign_key = ForeignKey.new('fk_trades_primary_reps', table_name, :rep_code, :primary_reps, :code)
            foreign_key.table.should == actual_table
          end
        end
      end


      describe '#ref_table' do
        it "equals to the table name passed in the initializer in various forms" do
          tables = {
            :dbo_primary_reps => :dbo_primary_reps,
            'dbo.PRIMARY_rEPs' => :dbo_primary_reps,
            'primary_reps' => :primary_reps,
            :br_CUSTOMER_Financial_Info => :br_customer_financial_info,
            'br.customer_financial_INFO' => :br_customer_financial_info
          }
          .each do |table_name, actual_table|
            foreign_key = ForeignKey.new('fk_trades_primary_reps', :direct_trades, :rep_code, table_name, :code)
            foreign_key.ref_table.should == actual_table
          end
        end
      end


      describe '#columns' do
        context "for regular foreign keys" do
          specify { foreign_key.columns.should include(:rep_code) }
        end

        context "for composite foreign keys" do
          it "includes all data columns specified as a composite key in various forms" do
            composite_foreign_key.columns.count.should == 2
            composite_foreign_key.columns.should include(:account_number)
            composite_foreign_key.columns.should include(:source_firm_code)
          end
        end
      end


      describe '#ref_columns' do
        context "for regular foreign keys" do
          specify { foreign_key.ref_columns.should include(:code) }
        end

        context "for composite foreign keys" do
          it "includes all data columns specified as a composite key in various forms" do
            composite_foreign_key.ref_columns.count.should == 2
            composite_foreign_key.ref_columns.should include(:number)
            composite_foreign_key.ref_columns.should include(:source)
          end
        end
      end
    end
  end
end
