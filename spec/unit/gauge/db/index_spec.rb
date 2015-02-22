# Eithery Lab., 2015.
# Class Gauge::DB::Index specs.

require 'spec_helper'

module Gauge
  module DB
    describe Index do
      let(:dbo_name) { "IDX_REP_CODE" }
      let(:dbo) { Index.new(dbo_name, :reps, :rep_code) }

      it_behaves_like "any composite database constraint"
    end
  end
end
