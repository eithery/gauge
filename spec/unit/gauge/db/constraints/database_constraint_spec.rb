# Eithery Lab, 2017
# Gauge::DB::Constraints::DatabaseConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      include Constants

      describe DatabaseConstraint do
        let(:db_constraint) { DatabaseConstraint.new(name: 'DC_DB_CONSTRAINT_NAME', table: :fund_accounts) }
        subject { db_constraint }

        it { expect(described_class).to be < DatabaseObject}

        it { should respond_to :table }
        it { should respond_to :== }


        describe '#table' do
          it "equals to the table name passed in the initializer" do
            TABLES.each do |table_name, actual_table|
              constraint = DatabaseConstraint.new(name: 'DC_DB_CONSTRAINT_NAME', table: table_name)
              expect(constraint.table).to be actual_table
            end
          end
        end


        describe '#==' do
          it "returns true for same database constraint instances" do
            expect(db_constraint.==(db_constraint)).to be true
          end

          it "returns true for database constraints on the same table" do
            constraint = DatabaseConstraint.new(name: 'dc_db_constraint_name', table: 'FUND_ACCOUNTS')
            expect(db_constraint).to_not equal(constraint)
            expect(db_constraint.==(constraint)).to be true
            expect(constraint.==(db_constraint)).to be true
          end

          it "returns true for same database constraints having different names" do
            constraint = DatabaseConstraint.new(name: 'dc_db_some_other_name', table: :FUND_ACCOUNTS)
            expect(db_constraint.==(constraint)).to be true
            expect(constraint.==(db_constraint)).to be true
          end

          it "returns false for database constraints on different tables" do
            constraint = DatabaseConstraint.new(name: 'DC_DB_CONSTRAINT_NAME', table: :reps)
            expect(db_constraint.==(constraint)).to be false
            expect(constraint.==(db_constraint)).to be false
          end

          it "returns false when other database constraint is nil" do
            expect(db_constraint.==(nil)).to be false
          end
        end
      end
    end
  end
end
