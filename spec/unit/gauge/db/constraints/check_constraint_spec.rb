# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::CheckConstraint specs.

require 'spec_helper'
require_relative 'constraint_spec_helper'

module Gauge
  module DB
    module Constraints
      describe CheckConstraint do
        let(:constraint_name) { 'ck_primary_reps_rep_code' }
        let(:constraint) { CheckConstraint.new('CK_Primary_Reps_Rep_Code', :primary_reps, :rep_code, 'len(rep_code) > 0') }
        let(:composite_constraint) do
          CheckConstraint.new('ck_direct_trades', :direct_trades, ['account_number', :source_firm_CODE],
            'len(rep_code) > 0')
        end

        it_behaves_like "any database constraint"

        subject { constraint }
        it { should respond_to :check_expression }


        describe '#check_expression' do
          it "equals to check expression passed in the initializer" do
            check_constraint = CheckConstraint.new('ck_rep_code_is_active', :reps, :is_active, 0..1)
            check_constraint.check_expression.should == (0..1)
          end
        end


        def constraint_for(table_name)
          CheckConstraint.new(constraint_name, table_name, :rep_code, 'len(rep_code) > 0')
        end
      end
    end
  end
end
