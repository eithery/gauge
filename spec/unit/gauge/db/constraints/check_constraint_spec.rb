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
        it { should respond_to :check_expression }


        describe '#check_expression' do
          it "equals to check expression passed in the initializer" do
            check_constraint = CheckConstraint.new('ck_rep_code_is_active', :reps, :is_active, 0..1)
            check_constraint.check_expression.should == (0..1)
          end
        end


        def constraint_for(*args)
          CheckConstraint.new(*args, 'len(rep_code) > 0')
        end
      end
    end
  end
end
