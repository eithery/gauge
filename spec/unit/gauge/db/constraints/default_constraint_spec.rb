# Eithery Lab, 2017
# Gauge::DB::Constraints::DefaultConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe DefaultConstraint do
        let(:default_constraint) do
          DefaultConstraint.new('DF_REPS_IS_ACTIVE', table: :reps, column: :is_active, default_value: true)
        end
        subject { default_constraint }

        it { expect(described_class).to be < DatabaseConstraint }

        it { should respond_to :column }
        it { should respond_to :default_value }


        describe '#column' do
          it "equals to the column name passed in the initializer" do
            [:is_active, 'is_active', 'IS_ACTIVE'].each do |column_name|
              constraint = DefaultConstraint.new('DF_REPS_IS_ACTIVE', table: :reps, column: column_name, default_value: true)
              expect(constraint.column).to be :is_active
            end
          end
        end


        describe '#default_value' do
          it "returns a value passed in the initializer" do
            expect(default_constraint.default_value).to be true
          end
        end
      end
    end
  end
end
