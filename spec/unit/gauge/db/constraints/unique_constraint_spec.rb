# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::UniqueConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe UniqueConstraint do
        let(:dbo_name) { 'UC_REPS_REP_CODE' }
        let(:dbo) { UniqueConstraint.new(dbo_name, :reps, :rep_code) }

        it_behaves_like "any composite database constraint"
      end
    end
  end
end
