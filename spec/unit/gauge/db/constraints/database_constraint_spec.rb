# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::DatabaseConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe DatabaseConstraint do
        let(:dbo_name) { 'DC_DB_CONSTRAINT_NAME' }
        let(:dbo) { constraint_for(dbo_name, :fund_accounts) }

        it_should_behave_like "any database constraint"


        def constraint_for(*args)
          DatabaseConstraint.new(args[0], args[1])
        end
      end
    end
  end
end
