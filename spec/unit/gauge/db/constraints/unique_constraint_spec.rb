# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::UniqueConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe UniqueConstraint do
        let(:dbo_name) { 'UC_REPS_REP_CODE' }
        let(:dbo) { UniqueConstraint.new(dbo_name, :reps, :rep_code) }

        it_behaves_like "any composite database constraint"


        describe '#==' do
          before { @unique_constraint = UniqueConstraint.new('uc_reps_rep_code', :reps, :rep_code) }

          context "when two constraints have the same state" do
            specify "they are equal" do
              constraint = UniqueConstraint.new('uc_reps_rep_code', :reps, :rep_code)
              @unique_constraint.should_not equal(constraint)
              @unique_constraint.should == constraint
              constraint.should == @unique_constraint
            end
          end

          context "when two constraints have the same state but different names" do
            specify "they are equal" do
              constraint = UniqueConstraint.new('uc_reps_12345', :reps, :rep_code)
              @unique_constraint.should == constraint
              constraint.should == @unique_constraint
            end
          end

          context "when two constraints are different" do
            specify "they are not equal" do
              constraint = UniqueConstraint.new('uc_reps_rep_code', :reps, :rep_id)
              @unique_constraint.should_not == constraint
              constraint.should_not == @unique_constraint
            end
          end

          context "when other unique constraint is nil" do
            subject { UniqueConstraint.new('uc_reps_rep_code', :reps, :rep_code) }
            it { should_not == nil }
          end

          context "for composite unique constraints" do
            before do
              @composite_unique_constraint = UniqueConstraint.new('uc_fund_accounts', :fund_accounts,
                [:fund_account_number, :cusip])
            end

            context "with same columns in various order" do
              specify "they are equal" do
                constraint = UniqueConstraint.new('uc_fund_accounts12', :fund_accounts, [:fund_account_number, :cusip])
                inverse_order_constraint = UniqueConstraint.new('uc_fund_accounts', :fund_accounts,
                  [:cusip, :fund_account_number])
                constraint.should == @composite_unique_constraint
                @composite_unique_constraint.should == constraint
                inverse_order_constraint.should == @composite_unique_constraint
                @composite_unique_constraint.should == inverse_order_constraint
              end
            end

            context "when the number of columns are different" do
              specify "they are not equal" do
                constraint = UniqueConstraint.new('uc_fund_accounts', :fund_accounts,
                  [:fund_account_number, :cusip, :ordinal])
                constraint.should_not == @composite_unique_constraint
                @composite_unique_constraint.should_not == constraint
              end
            end
          end
        end
      end
    end
  end
end
