# Eithery Lab, 2017
# Gauge::DB::Constraints::CompositeConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe CompositeConstraint do

        let(:one_column_constraint) do
          CompositeConstraint.new(name: 'CC_COMPOSITE_CONSTRAINT_NAME', table: :trades, columns: :rep_code)
        end
        let(:composite_constraint) { one_column_constraint }
        let(:multiple_columns_constraint) do
          CompositeConstraint.new(name: 'CC_COMPOSITE_CONSTRAINT_NAME', table: :trades,
            columns: [:office_code, :rep_code])
        end

        subject { one_column_constraint }


        it { expect(described_class).to be < DatabaseConstraint }

        it { should respond_to :columns }
        it { should respond_to :composite? }
        it { should respond_to :== }


        describe '#columns' do
          context "when a constraint is applied to one column" do
            it { expect(one_column_constraint).to have(1).column }
            it { expect(one_column_constraint.columns).to include(:rep_code) }
          end

          context "when a constraint is applied to multiple columns" do
            it "includes all specified data columns" do
              expect(multiple_columns_constraint).to have(2).columns
              expect(multiple_columns_constraint.columns).to include(:office_code, :rep_code)
            end
          end
        end


        describe '#composite?' do
          context "for regular (single column) database constraints" do
            it { expect(one_column_constraint).to_not be_composite }
          end

          context "for composite (multiple column) database constraints" do
            it { expect(multiple_columns_constraint).to be_composite }
          end
        end


        describe '#==' do
          it "returns true for composite constraints on the same table and columns" do
            constraint = CompositeConstraint.new(name: 'cc_composite_constraint_name', table: 'TRADES',
              columns: 'rep_code')
            expect(composite_constraint).to_not equal(constraint)
            expect(composite_constraint.==(constraint)).to be true
            expect(constraint.==(composite_constraint)).to be true
          end

          it "returns true for same composite constraints having different names" do
            constraint = CompositeConstraint.new(name: 'cc_other_constraint_name', table: :TRADES,
              columns: 'REP_CODE')
            expect(composite_constraint.==(constraint)).to be true
            expect(constraint.==(composite_constraint)).to be true
          end

          it "returns false for composite constraints on different tables or columns" do
            constraint = CompositeConstraint.new(name: 'CC_COMPOSITE_CONSTRAINT_NAME', table: :trades,
              columns: :office_code)
            other_table_constraint = CompositeConstraint.new(name: 'CC_COMPOSITE_CONSTRAINT_NAME',
              table: :fund_accounts, columns: :rep_code)

            expect(composite_constraint.==(constraint)).to be false
            expect(constraint.==(composite_constraint)).to be false
            expect(composite_constraint.==(other_table_constraint)).to be false
            expect(other_table_constraint.==(composite_constraint)).to be false
          end
        end
      end
    end
  end
end
