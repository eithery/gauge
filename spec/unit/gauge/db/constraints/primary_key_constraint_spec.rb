# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::PrimaryKeyConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe PrimaryKeyConstraint do
        let(:key) { PrimaryKeyConstraint.new('PK_Primary_Reps', :dbo_primary_reps, :rep_code) }
        let(:composite_key) do
          PrimaryKeyConstraint.new('pk_fund_account_info', :fund_accounts,
            [:fund_account_number, :CUSIP, 'Carrier_CODE'])
        end
        subject { key }

        it { should respond_to :name }
        it { should respond_to :table }
        it { should respond_to :columns }
        it { should respond_to :clustered?, :composite? }


        describe '#name' do
          it "equals to the key name in downcase passed in the initializer" do
            key.name.should == 'pk_primary_reps'
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
              primary_key = PrimaryKeyConstraint.new('pk_primary_reps', table_name, :rep_code)
              primary_key.table.should == actual_table
            end
          end
        end


        describe '#columns' do
          context "for regular primary keys" do
            specify { key.columns.should include(:rep_code) }
          end

          context "for composite primary keys" do
            it "includes all data columns specified as a composite key in various forms" do
              composite_key.columns.count.should == 3
              composite_key.columns.should include(:fund_account_number)
              composite_key.columns.should include(:cusip)
              composite_key.columns.should include(:carrier_code)
            end
          end
        end


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


        describe '#composite?' do
          context "for regular primary keys" do
            it { should_not be_composite }
          end

          context "for composite primary keys" do
            specify { composite_key.should be_composite }
          end
        end
      end
    end
  end
end
