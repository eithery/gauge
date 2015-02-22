# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::CompositeConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe CompositeConstraint do
        let(:dbo_name) { 'CC_COMPOSITE_CONSTRAINT_NAME' }
        let(:dbo) { CompositeConstraint.new(dbo_name, :trades, :rep_code) }

        it_should_behave_like "any composite database constraint"
      end
    end
  end
end
