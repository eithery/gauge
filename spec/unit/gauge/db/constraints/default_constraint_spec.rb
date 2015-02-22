# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::DefaultConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe DefaultConstraint do
        let(:dbo_name) { 'DF_Reps_Is_Active' }
        let(:dbo) { DefaultConstraint.new(dbo_name, :reps, :is_active, true) }

        let(:constraint_name) { 'df_primary_reps_rep_code' }
        let(:constraint) { DefaultConstraint.new('DF_Primary_Reps_Rep_Code', :dbo_primary_reps, :rep_code, 'R001') }
        let(:composite_constraint) do
          DefaultConstraint.new('df_direct_trades_account', :direct_trades, ['account_number', :source_firm_CODE], 'A000001')
        end

        it_behaves_like "any database constraint"

        subject { constraint }
        it { should respond_to :default_value }


        describe '#default_value' do
          it "equals to the default value passed in the initializer" do
            default_constraint = DefaultConstraint.new('df_reps_is_active', :reps, :is_active, true)
            default_constraint.default_value.should be true
          end
        end


        def constraint_for(table_name)
          DefaultConstraint.new(constraint_name, table_name, :is_enabled, true)
        end
      end
    end
  end
end
