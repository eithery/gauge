# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::UniqueConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe UniqueConstraint do
        let(:constraint) { UniqueConstraint.new('UC_Primary_Reps', :dbo_primary_reps, :rep_code) }
        subject { constraint }

        it { should respond_to :name }
        it { should respond_to :table }
        it { should respond_to :columns }


        describe '#name' do
          it "equals to the constraint name in downcase passed in the initializer" do
            constraint.name.should == 'uc_primary_reps'
          end
        end


        describe '#table' do
          it "equals to the table name passed in the initializer in various forms" do
            tables = {
              :dbo_primary_reps => :dbo_primary_reps,
              'dbo.PRIMARY_rEPs' => :dbo_primary_reps,
              'primary_reps' => :primary_reps,
              :br_CUSTOMER_Financial_Info => :br_customer_financial_info,
              'br.customer_financial_INFO' => :br_customer_financial_info
            }
            .each do |table_name, actual_table|
              unique_constraint = UniqueConstraint.new('uc_primary_reps', table_name, :rep_code)
              unique_constraint.table.should == actual_table
            end
          end
        end


        describe '#columns' do
          context "for one column unique constraints" do
            specify { constraint.columns.should include(:rep_code) }
          end

          context "for multi-columns unique constraints" do
            before do
              @unique_constraint = UniqueConstraint.new('uc_fund_account_info', :fund_accounts, ['fund_account_number', :CUSIP])
            end
            it "includes all data columns defined in the unique constraint in various forms" do
              @unique_constraint.columns.count.should == 2
              @unique_constraint.columns.should include(:fund_account_number)
              @unique_constraint.columns.should include(:cusip)
            end
          end
        end
      end
    end
  end
end
