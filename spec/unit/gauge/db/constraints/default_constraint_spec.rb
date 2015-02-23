# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::DefaultConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe DefaultConstraint do
        let(:dbo_name) { 'DF_REPS_IS_ACTIVE' }
        let(:dbo) { DefaultConstraint.new(dbo_name, :reps, :is_active, true) }
        subject { dbo }

        it_behaves_like "any database constraint"

        it { should respond_to :column }
        it { should respond_to :default_value }


        describe '#column' do
          it "equals to the column name passed in the initializer in various forms" do
            [:is_active, 'is_active', 'IS_ACTIVE'].each do |column_name|
              default_constraint = DefaultConstraint.new(dbo_name, :reps, column_name, true)
              default_constraint.column.should == :is_active
            end
          end
        end


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
