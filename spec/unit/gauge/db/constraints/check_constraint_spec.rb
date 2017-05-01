# Eithery Lab, 2017
# Gauge::DB::Constraints::CheckConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe CheckConstraint do
        let(:check_constraint) do
          CheckConstraint.new(name: 'CK_REPS_IS_ACTIVE', table: :reps, columns: :is_active, check: 0..1)
        end

        subject { check_constraint }

        it { expect(described_class).to be < CompositeConstraint }

        it { should respond_to :expression }
        it { should respond_to :== }


        describe '#expression' do
          it "returns a value passed in the initializer" do
            constraint = CheckConstraint.new(name: 'ck_financial_info_level', table: :account_financial_info,
              columns: :level_value, check: '>= 0')

            expect(check_constraint.expression).to eq (0..1)
            expect(constraint.expression).to eq '>= 0'
          end
        end


        describe '#==' do
          it "returns true for check constraints on the same table, column, and expression" do
            constraint = CheckConstraint.new(name: 'ck_reps_is_active', table: 'REPS',
              columns: 'is_active', check: 0..1)
            expect(check_constraint).to_not equal(constraint)
            expect(check_constraint.==(constraint)).to be true
            expect(constraint.==(check_constraint)).to be true
          end

          it "returns true for same check constraints having different names" do
            constraint = CheckConstraint.new(name: 'ck_reps_12345', table: :REPS,
              columns: 'IS_ACTIVE', check: 0..1)
            expect(check_constraint.==(constraint)).to be true
            expect(constraint.==(check_constraint)).to be true
          end

          it "returns false for check constraints on different tables or columns" do
            constraint = CheckConstraint.new(name: 'ck_reps_is_active', table: :reps,
              columns: :is_enabled, check: 0..1)
            other_table_constraint = CheckConstraint.new(name: 'ck_reps_is_active', table: :offices,
              columns: :is_active, check: 0..1)

            expect(check_constraint.==(constraint)).to be false
            expect(constraint.==(check_constraint)).to be false
            expect(check_constraint.==(other_table_constraint)).to be false
            expect(other_table_constraint.==(check_constraint)).to be false
          end

          it "returns false for check constraints with different check expressions" do
            constraint = CheckConstraint.new(name: 'ck_reps_is_active', table: :reps,
              columns: :is_active, check: '>= 2')
            expect(check_constraint.==(constraint)).to be false
            expect(constraint.==(check_constraint)).to be false
          end
        end
      end
    end
  end
end
