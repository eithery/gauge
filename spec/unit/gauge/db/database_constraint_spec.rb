# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::DatabaseConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe DatabaseConstraint do
        let(:dbo_name) { 'DC_Database_Constraint_Name' }
        let(:dbo) { DatabaseConstraint.new(dbo_name, :fund_accounts, :rep_code) }
        let(:constraint) { dbo }
        let(:composite_constraint) do
          DatabaseConstraint.new(dbo_name, :trades, [:account_number, :source_firm_code])
        end

        it_should_behave_like "any database constraint"


        def constraint_for(table_name)
          DatabaseConstraint.new(dbo_name, table_name, :rep_code)
        end
      end
    end
  end
end
