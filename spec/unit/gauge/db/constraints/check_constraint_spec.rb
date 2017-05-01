# Eithery Lab, 2017
# Gauge::DB::Constraints::CheckConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe CheckConstraint do
        let(:check_constraint) do
          CheckConstraint.new('CK_REPS_IS_ACTIVE', table: :reps, columns: :is_active, check: 0..1)
        end
        subject { check_constraint }

        it { expect(described_class).to be < CompositeConstraint }

        it { should respond_to :expression }


        describe '#expression' do
          it "returns a value passed in the initializer" do
            constraint = CheckConstraint.new('ck_financial_info_level', table: :account_financial_info,
              columns: :level_value, check: '>= 0')

            expect(check_constraint.expression).to eq (0..1)
            expect(constraint.expression).to eq '>= 0'
          end
        end
      end
    end
  end
end
