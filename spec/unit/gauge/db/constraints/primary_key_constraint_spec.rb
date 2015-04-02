# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::PrimaryKeyConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe PrimaryKeyConstraint do
        let(:dbo_name) { 'PK_REPS' }
        let(:dbo) { PrimaryKeyConstraint.new(dbo_name, :reps, :rep_code) }
        subject { dbo }

        it_behaves_like "any composite database constraint"
        it { should respond_to :clustered? }


        describe '#clustered?' do
          context "by default" do
            it { should be_clustered }
          end

          context "when specified as nonclustered" do
            before { @nonclustered_key = PrimaryKeyConstraint.new('pk_reps', :reps, :id, clustered: false) }
            specify { @nonclustered_key.should_not be_clustered }
          end

          context "when specified as clustered" do
            before { @clustered_key = PrimaryKeyConstraint.new('pk_reps', :reps, :id, clustered: true) }
            specify { @clustered_key.should be_clustered }
          end

          context "when specified with incorrect value" do
            before { @clustered_key = PrimaryKeyConstraint.new('pk_reps', :reps, :id, clustered: 'no') }
            specify { @clustered_key.should be_clustered }
          end
        end


        describe '#==' do
          before { @primary_key = PrimaryKeyConstraint.new('pk_reps', :reps, :rep_code) }

          context "when two primary keys are the same instance" do
            specify "they are equal" do
              @primary_key.should == @primary_key
            end
          end

          context "when two primary keys have the same state" do
            specify "they are equal" do
              key = PrimaryKeyConstraint.new('pk_reps', :reps, :rep_code)
              key.should_not equal(@primary_key)
              key.should == @primary_key
              @primary_key.should == key
            end
          end

          context "when two primary keys have the same state but different names" do
            specify "they are equal" do
              key = PrimaryKeyConstraint.new('pk_primary_reps_123456', :reps, :rep_code)
              key.should == @primary_key
              @primary_key.should == key
            end
          end

          context "when two primary keys are different" do
            specify "they are not equal" do
              key = PrimaryKeyConstraint.new('pk_reps', :reps, :rep_code, clustered: false)
              key.should_not == @primary_key
              @primary_key.should_not == key
            end
          end

          context "for composite primary keys" do
            before do
              @composite_key = PrimaryKeyConstraint.new('pk_fund_accounts', :fund_accounts,
                [:fund_account_number, :cusip], clustered: false)
            end

            context "with same columns in various order" do
              specify "they are equal" do
                key = PrimaryKeyConstraint.new('pk_fund_accounts', :fund_accounts,
                  [:fund_account_number, :cusip], clustered: false)
                inverse_order_key = PrimaryKeyConstraint.new('pk_fund_accounts', :fund_accounts,
                  [:cusip, :fund_account_number], clustered: false)
                key.should == @composite_key
                @composite_key.should == key
                inverse_order_key.should == @composite_key
                @composite_key.should == inverse_order_key
              end
            end

            context "when the number of columns are different" do
              specify "they are not equal" do
                key = PrimaryKeyConstraint.new('pk_fund_accounts', :fund_accounts,
                  [:fund_account_number, :cusip, :ordinal], clustered: false)
                key.should_not == @composite_key
                @composite_key.should_not == key
              end
            end
          end
        end
      end
    end
  end
end
