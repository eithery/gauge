# Eithery Lab., 2015.
# Class Gauge::DB::Index specs.

require 'spec_helper'

module Gauge
  module DB
    describe Index do
      let(:dbo_name) { "IDX_REP_CODE" }
      let(:dbo) { Index.new(dbo_name, :reps, :rep_code) }
      subject { dbo }

      it_behaves_like "any composite database constraint"

      it { should respond_to :clustered? }
      it { should respond_to :unique? }


      describe '#clustered?' do
        context "by default" do
          it { should_not be_clustered }
        end

        context "when specified as clustered" do
          before { @clustered_index = Index.new('idx_rep_code', :reps, :rep_code, clustered: true) }
          specify { @clustered_index.should be_clustered }
        end

        context "when specified as non clustered" do
          before { @nonclustered_index = Index.new('idx_rep_code', :reps, :rep_code, clustered: false) }
          specify { @nonclustered_index.should_not be_clustered }
        end

        context "when specified with incorrect value" do
          before { @nonclustered_index = Index.new('idx_rep_code', :reps, :rep_code, clustered: 'yes') }
          specify { @nonclustered_index.should_not be_clustered }
        end
      end


      describe '#unique' do
        context "by default" do
          it { should_not be_unique }
        end

        context "when specified as unique" do
          before { @unique_index = Index.new('idx_rep_code', :reps, :rep_code, unique: true) }
          specify { @unique_index.should be_unique }
        end

        context "when specified as clustered" do
          before { @clustered_index = Index.new('idx_rep_code', :reps, :rep_code, clustered: true) }
          specify { @clustered_index.should be_unique }
        end

        context "when specified as clustered but not unique" do
          before { @clustered_index = Index.new('idx_rep_code', :reps, :rep_code, clustered: true, unique: false) }
          specify { @clustered_index.should be_unique }
        end

        context "when specified as not unique" do
          before { @nonunique_index = Index.new('idx_rep_code', :reps, :rep_code, unique: false) }
          specify { @nonunique_index.should_not be_unique }
        end

        context "when specified with incorrect value" do
          before { @nonunique_index = Index.new('idx_rep_code', :reps, :rep_code, unique: 'yes') }
          specify { @nonunique_index.should_not be_unique }
        end
      end


      describe '#==' do
        before { @index = Index.new('idx_reps_rep_code', :reps, :rep_code) }

        context "when two indexes represent the same instance" do
          specify "they are equal" do
            @index.should == @index
          end
        end

        context "when two indexes have the same state" do
          specify "they are equal" do
            index = Index.new('idx_reps_rep_code', :reps, :rep_code)
            index.should_not equal(@index)
            index.should == @index
            @index.should == index
          end
        end

        context "when two indexes have the same state but different names" do
          specify "they are equal" do
            index = Index.new('idx_primary_reps_123456', :reps, :rep_code)
            index.should == @index
            @index.should == index
          end
        end

        context "when two indexes are different" do
          specify "they are not equal" do
            index = Index.new('idx_reps_rep_code', :reps, :rep_code, unique: true)
            index.should_not == @index
            @index.should_not == index
          end
        end

        context "for composite indexes" do
          before { @composite_index = Index.new('idx_fund_accounts', :fund_accounts, [:fund_account_number, :cusip]) }

          context "with same columns in various order" do
            specify "they are equal" do
              index = Index.new('idx_fund_accounts', :fund_accounts, [:fund_account_number, :cusip])
              inverse_order_index = Index.new('idx_fund_accounts', :fund_accounts, [:cusip, :fund_account_number])
              index.should == @composite_index
              @composite_index.should == index
              inverse_order_index.should == @composite_index
              @composite_index.should == inverse_order_index
            end
          end

          context "when the number of columns are different" do
            specify "they are not equal" do
              index = Index.new('idx_fund_accounts', :fund_accounts, [:fund_account_number, :cusip, :ordinal])
              index.should_not == @composite_index
              @composite_index.should_not == index
            end
          end
        end

        context "for clustered indexes" do
          before { @clustered_index = Index.new('idx_reps_rep_code', :reps, :rep_code, clustered: true) }
          it "does not equal to the unique index on the same column but not clustered" do
            index = Index.new('idx_reps_rep_code', :reps, :rep_code, unique: true)
            @clustered_index.should_not == index
            index.should_not == @clustered_index
          end
        end
      end
    end
  end
end
