# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::DatabaseConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe DatabaseConstraint do
        let(:constraint) { DatabaseConstraint.new('DC_Primary_Reps', :dbo_primary_reps, :rep_code) }
        subject { constraint }

        it { should respond_to :name }
        it { should respond_to :table }
        it { should respond_to :columns }


        describe '#name' do
          it "equals to the constraint name in downcase passed in the initializer" do
            constraint.name.should == 'dc_primary_reps'
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
              db_constraint = DatabaseConstraint.new('dc_primary_reps', table_name, :rep_code)
              db_constraint.table.should == actual_table
            end
          end
        end


        describe '#columns' do
          context "when constraint is applied to one column" do
            specify { constraint.columns.should include(:rep_code) }
          end

          context "when constraint is applied to multiple columns" do
            before do
              @constraint = DatabaseConstraint.new('dc_fund_account_info', :fund_accounts, ['fund_account_number', :CUSIP])
            end
            it "includes all data columns specified in the constraint in various forms" do
              @constraint.columns.count.should == 2
              @constraint.columns.should include(:fund_account_number)
              @constraint.columns.should include(:cusip)
            end
          end
        end
      end
    end
  end
end
