# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::ForeignKeyConstraint specs.

require 'spec_helper'
require_relative 'constraint_spec_helper'

module Gauge
  module DB
    module Constraints
      include ConstraintSpecHelper

      describe ForeignKeyConstraint do
        let(:constraint_name) { 'fk_trade_primary_reps' }
        let(:constraint) { ForeignKeyConstraint.new('FK_Trade_Primary_Reps', :direct_trades, :rep_code, :primary_reps, :code) }
        let(:composite_constraint) do
          ForeignKeyConstraint.new('fk_trade_accounts', :direct_trades, ['account_number', :source_firm_CODE],
            :accounts, [:number, 'Source'])
        end

        it_behaves_like "any database constraint"

        subject { constraint }

        it { should respond_to :ref_table }
        it { should respond_to :ref_columns }


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
              foreign_key = ForeignKeyConstraint.new('fk_trades_primary_reps', :direct_trades, :rep_code, table_name, :code)
              foreign_key.ref_table.should == actual_table
            end
          end
        end


        describe '#ref_columns' do
          context "for regular foreign keys" do
            specify { constraint.ref_columns.should include(:code) }
          end

          context "for composite foreign keys" do
            it "includes all data columns specified as a composite key in various forms" do
              composite_constraint.ref_columns.count.should == 2
              composite_constraint.ref_columns.should include(:number)
              composite_constraint.ref_columns.should include(:source)
            end
          end
        end


        def constraint_for(table_name)
          ForeignKeyConstraint.new(constraint_name, table_name, :rep_code, :primary_reps, :code)
        end
      end
    end
  end
end
