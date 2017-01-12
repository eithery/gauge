# Eithery Lab, 2017
# Gauge::DB::Constraints::DatabaseConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      include Constants

      describe DatabaseConstraint do
        subject { DatabaseConstraint.new('DC_DB_CONSTRAINT_NAME', table: :fund_accounts) }

        it { expect(described_class).to be < DatabaseObject}

        it { should respond_to :table }


        describe '#table' do
          it "equals to the table name passed in the initializer" do
            TABLES.each do |table_name, actual_table|
              constraint = DatabaseConstraint.new 'DC_DB_CONSTRAINT_NAME', table: table_name
              expect(constraint.table).to be actual_table
            end
          end
        end
      end
    end
  end
end
