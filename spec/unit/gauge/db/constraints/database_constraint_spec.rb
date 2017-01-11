# Eithery Lab, 2017
# Gauge::DB::Constraints::DatabaseConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe DatabaseConstraint, f: true do
        let(:dbo_name) { 'DC_DB_CONSTRAINT_NAME' }
        let(:dbo) { DatabaseConstraint.new(dbo_name, table: :fund_accounts) }
        subject { dbo }

        it { expect(described_class).to be < DatabaseObject}

        it { should respond_to :table }


        describe '#table' do
          it "equals to the table name passed in the initializer" do
            TABLES.each do |table_name, actual_table|
              db_constraint = DatabaseConstraint.new dbo_name, table: table_name
              expect(db_constraint.table).to eq actual_table
            end
          end
        end
      end


  private

      TABLES = {
        :primary_reps => :dbo_primary_reps,
        'dbo.PRIMARY_rEPs' => :dbo_primary_reps,
        'primary_reps' => :dbo_primary_reps,
        :primary_REPS => :dbo_primary_reps,
        '"dbo"."primary_Reps"' => :dbo_primary_reps,
        '[rep_profile].[dbo].[primary_reps]' => :dbo_primary_reps,
        :bnr_CUSTOMER_Financial_Info => :dbo_bnr_customer_financial_info,
        'bnr.customer_financial_INFO' => :bnr_customer_financial_info,
        '"Rep_Profile"."bnr"."Customer_financial_info"' => :bnr_customer_financial_info
      }
    end
  end
end
