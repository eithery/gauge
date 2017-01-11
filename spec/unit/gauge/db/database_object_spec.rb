# Eithery Lab, 2017
# Gauge::DB::DatabaseObject specs

require 'spec_helper'

module Gauge
  module DB
    describe DatabaseObject do
      let(:dbo) { DatabaseObject.new('PK_REP_CODE') }
      subject { dbo }

      it { should respond_to :name }
      it { should respond_to :to_sym }


      describe '#name' do
        it "equals to the object name passed in the initializer" do
          expect(dbo.name).to eq 'PK_REP_CODE'
        end
      end


      describe '#to_sym' do
        it "converts a database object name to downcase symbol" do
          expect(DatabaseObject.new('PK_REP_CODE').to_sym).to be :pk_rep_code
          expect(DatabaseObject.new(:Reps).to_sym).to be :reps
          expect(DatabaseObject.new('dBo.master_Accounts').to_sym).to be :dbo_master_accounts
          expect(DatabaseObject.new('ref.contract_Types').to_sym).to be :ref_contract_types
        end
      end
    end
  end
end
