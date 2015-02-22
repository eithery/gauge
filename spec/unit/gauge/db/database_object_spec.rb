# Eithery Lab., 2015.
# Class Gauge::DB::DatabaseObject specs.

require 'spec_helper'

module Gauge
  module DB
    describe DatabaseObject do
      let(:clazz) { DatabaseObject }
      let(:dbo_name) { 'PK_Rep_Code' }

      it_should_behave_like "any database object"
    end
  end
end
