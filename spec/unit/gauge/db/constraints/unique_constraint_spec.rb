# Eithery Lab, 2017
# Gauge::DB::Constraints::UniqueConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe UniqueConstraint do

        let(:unique_constraint) { UniqueConstraint.new(name: 'UC_REPS_REP_CODE', table: :reps, columns: :rep_code) }
        let(:composite_unique_constraint) do
          UniqueConstraint.new(name: 'UC_FUND_ACCOUNTS', table: :fund_accounts,
            columns: [:fund_account_number, :cusip])
        end

        subject { unique_constraint }

        it { expect(described_class).to be < CompositeConstraint }
        it { should respond_to :== }


        describe '#==' do
          it "returns true for unique constraints on the same table and column" do
            constraint = UniqueConstraint.new(name: 'uc_reps_rep_code', table: :reps, columns: :rep_code)
            expect(unique_constraint).to_not equal(constraint)
            expect(unique_constraint.==(constraint)).to be true
            expect(constraint.==(unique_constraint)).to be true
          end

          it "returns true for unique constrains on the same table and column but having different names" do
            constraint = UniqueConstraint.new(name: 'uc_reps_12345', table: :reps, columns: :rep_code)
            expect(unique_constraint.==(constraint)).to be true
            expect(constraint.==(unique_constraint)).to be true
          end

          it "returns false for different unique constraints" do
            constraint = UniqueConstraint.new(name: 'UC_REPS_REP_CODE', table: :reps, columns: :rep_id)
            expect(unique_constraint.==(constraint)).to be false
            expect(constraint.==(unique_constraint)).to be false
          end

          context "for composite unique constraints" do
            it "returns true for unique constraints on same columns in various order" do
              constraint = UniqueConstraint.new(name: 'uc_fund_accounts', table: :fund_accounts,
                columns: [:fund_account_number, :cusip])
              inverse_order_constraint = UniqueConstraint.new(name: 'uc_fund_accounts', table: :fund_accounts,
                columns: [:cusip, :fund_account_number])

              expect(composite_unique_constraint.==(constraint)).to be true
              expect(constraint.==(composite_unique_constraint)).to be true
              expect(composite_unique_constraint.==(inverse_order_constraint)).to be true
              expect(inverse_order_constraint.==(composite_unique_constraint)).to be true
            end

            it "returns false for different number of columns" do
              constraint = UniqueConstraint.new(name: 'uc_fund_accounts', table: :fund_accounts,
                columns: [:fund_account_number, :cusip, :ordinal])
              expect(composite_unique_constraint.==(constraint)).to be false
              expect(constraint.==(composite_unique_constraint)).to be false
            end
          end
        end
      end
    end
  end
end
