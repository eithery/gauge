# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::CheckConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe CheckConstraint do
        let(:dbo_name) { 'CK_REPS_IS_ACTIVE' }
        let(:dbo) { CheckConstraint.new(dbo_name, :reps, :is_active, 0..1) }
        subject { dbo }

        it_behaves_like "any composite database constraint"
        it { should respond_to :expression }


        describe '#expression' do
          subject { @check_constraint.expression }

          context "for range check" do
            before { @check_constraint = CheckConstraint.new('ck_rep_code_is_active', :reps, :is_active, 0..1) }
            it { should == (0..1) }
          end

          context "for comparison check" do
            before do
              @check_constraint = CheckConstraint.new('ck_financial_info_level', :account_financial_info,
                :level_value, '>= 0')
            end
            it { should == '>= 0' }
          end
        end


        def constraint_for(*args)
          CheckConstraint.new(*args, 'len(rep_code) > 0')
        end
      end
    end
  end
end
