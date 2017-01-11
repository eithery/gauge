# Eithery Lab, 2017
# Gauge::DB::DatabaseObject specs

require 'spec_helper'

module Gauge
  module DB
    include SharedExamples

    describe DatabaseObject do
      let(:dbo_name) { 'PK_REP_CODE' }
      let(:dbo) { DatabaseObject.new(dbo_name) }

      it_behaves_like "any database object"

      it { expect(dbo).to respond_to :to_sym }


      describe '#to_sym' do
        it "converts a database object name to downcase symbol" do
          expect(DatabaseObject.new(dbo_name).to_sym).to be :pk_rep_code
          expect(DatabaseObject.new(:Reps).to_sym).to be :reps
          expect(DatabaseObject.new('dBo.master_Accounts').to_sym).to be :dbo_master_accounts
          expect(DatabaseObject.new('ref.contract_Types').to_sym).to be :ref_contract_types
        end
      end
    end
  end
end
