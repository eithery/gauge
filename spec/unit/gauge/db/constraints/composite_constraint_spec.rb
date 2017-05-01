# Eithery Lab, 2017
# Gauge::DB::Constraints::CompositeConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe CompositeConstraint do
        let(:one_column_constraint) do
          CompositeConstraint.new('CC_COMPOSITE_CONSTRAINT_NAME', table: :trades, columns: :rep_code)
        end
        let(:multiple_columns_constraint) do
          CompositeConstraint.new('CC_COMPOSITE_CONSTRAINT_NAME', table: :trades, columns: [:office_code, :rep_code])
        end
        subject { one_column_constraint }


        it { expect(described_class).to be < DatabaseConstraint }

        it { should respond_to :columns }
        it { should respond_to :composite? }


        describe '#columns' do
          context "when a constraint is applied to one column" do
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
      end
    end
  end
end
