# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::ConstraintSpecHelper
# Provides the set of helper methods for database constraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      module ConstraintSpecHelper

        shared_examples_for "any database constraint" do
          subject { constraint }

          it { should respond_to :name }
          it { should respond_to :table }
          it { should respond_to :columns }


          describe '#name' do
            it "equals to the constraint name in downcase passed in the initializer" do
              constraint.name.should == constraint_name
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
                db_constraint = constraint_for table_name
                db_constraint.table.should == actual_table
              end
            end
          end


          describe '#columns' do
            context "when constraint is applied to one column" do
              specify { constraint.columns.should include(:rep_code) }
            end

            context "when constraint is applied to multiple columns" do
              it "includes all data columns specified in the constraint in various forms" do
                composite_constraint.columns.count.should == 2
                composite_constraint.columns.should include(:account_number)
                composite_constraint.columns.should include(:source_firm_code)
              end
            end
          end
        end
      end
    end
  end
end
