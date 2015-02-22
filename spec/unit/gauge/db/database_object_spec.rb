# Eithery Lab., 2015.
# Class Gauge::DB::DatabaseObject specs.

require 'spec_helper'

module Gauge
  module DB
    describe DatabaseObject do
      let(:dbo_name) { 'PK_REP_CODE' }
      let(:dbo) { DatabaseObject.new(dbo_name) }

      it_should_behave_like "any database object"
    end
  end
end
