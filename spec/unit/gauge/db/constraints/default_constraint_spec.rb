# Eithery Lab, 2017
# Gauge::DB::Constraints::DefaultConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe DefaultConstraint do
        let(:default_constraint) do
          DefaultConstraint.new(name: 'DF_REPS_IS_ACTIVE', table: :reps, column: :is_active, default_value: true)
        end
        subject { default_constraint }

        it { expect(described_class).to be < DatabaseConstraint }

        it { should respond_to :column }
        it { should respond_to :default_value }
        it { should respond_to :== }


        describe '#column' do
          it "equals to the column name passed in the initializer" do
            [:is_active, 'is_active', 'IS_ACTIVE'].each do |column_name|
              constraint = DefaultConstraint.new(name: 'DF_REPS_IS_ACTIVE', table: :reps,
                column: column_name, default_value: true)
              expect(constraint.column).to be :is_active
            end
          end
        end


        describe '#default_value' do
          it "returns a value passed in the initializer" do
            expect(default_constraint.default_value).to be true
            expect(DefaultConstraint.new(name: 'df_reps_office_type', table: :reps, column: :office_id,
              default_value: :region).default_value).to be :region
          end
        end


        describe '#==' do
          it "returns true for default constraints on the same table, column, and default value" do
            constraint = DefaultConstraint.new(name: 'df_reps_is_active', table: 'REPS',
              column: 'is_active', default_value: true)
            expect(default_constraint).to_not equal(constraint)
            expect(default_constraint.==(constraint)).to be true
            expect(constraint.==(default_constraint)).to be true
          end

          it "returns true for same default constraints having different names" do
            constraint = DefaultConstraint.new(name: 'df_reps_12345', table: :REPS,
              column: 'IS_ACTIVE', default_value: true)
            expect(default_constraint.==(constraint)).to be true
            expect(constraint.==(default_constraint)).to be true
          end

          it "returns false for default constraints on different tables or columns" do
            constraint = DefaultConstraint.new(name: 'df_reps_is_active', table: :reps,
              column: :is_enabled, default_value: true)
            other_table_constraint = DefaultConstraint.new(name: 'df_reps_is_active', table: :offices,
              column: :is_active, default_value: true)

            expect(default_constraint.==(constraint)).to be false
            expect(constraint.==(default_constraint)).to be false
            expect(default_constraint.==(other_table_constraint)).to be false
            expect(other_table_constraint.==(default_constraint)).to be false
          end

          it "returns false for default constraints with different default values" do
            constraint = DefaultConstraint.new(name: 'df_reps_is_active', table: :reps,
              column: :is_active, default_value: false)
            expect(default_constraint.==(constraint)).to be false
            expect(constraint.==(default_constraint)).to be false
          end
        end
      end
    end
  end
end
