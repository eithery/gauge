# Eithery Lab, 2017
# Gauge::DB::Constraints::DatabaseConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe DatabaseConstraint, f: true do
        let(:dbo_name) { 'DC_DB_CONSTRAINT_NAME' }
        let(:dbo) { constraint_for(dbo_name, :fund_accounts) }

        it_behaves_like "any database constraint"


        def constraint_for(*args)
          DatabaseConstraint.new(args[0], table: args[1])
        end
      end
    end
  end
end
