# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::DefaultConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe DefaultConstraint do
        let(:dbo_name) { 'DF_Reps_Is_Active' }
        let(:dbo) { DefaultConstraint.new(dbo_name, :reps, :is_active, true) }
        subject { dbo }

        it_behaves_like "any database constraint"
        it { should respond_to :default_value }


        describe '#default_value' do
          it "equals to the default value passed in the initializer" do
            default_constraint = DefaultConstraint.new('df_reps_is_active', :reps, :is_active, true)
            default_constraint.default_value.should be true
          end
        end


        def constraint_for(*args)
          DefaultConstraint.new(*args, 'R0001')
        end
      end
    end
  end
end
