# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::UniqueConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe UniqueConstraint do
        let(:dbo_name) { 'UC_Primary_Reps' }
        let(:dbo) { UniqueConstraint.new(constraint_name, :reps, :rep_code) }

        let(:constraint_name) { 'uc_primary_reps' }
        let(:constraint) { UniqueConstraint.new('UC_Primary_Reps', :dbo_primary_reps, :rep_code) }
        let(:composite_constraint) do
          UniqueConstraint.new('uc_direct_trades', :direct_trades, ['account_number', :source_firm_CODE])
        end

        it_behaves_like "any database constraint"


        def constraint_for(table_name)
          UniqueConstraint.new(constraint_name, table_name, :rep_code)
        end
      end
    end
  end
end
