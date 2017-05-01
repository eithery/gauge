# Eithery Lab, 2017
# Gauge::DB::DatabaseObject specs

require 'spec_helper'

module Gauge
  module DB
    describe DatabaseObject do
      let(:dbo) { DatabaseObject.new(name: 'PK_REP_CODE') }
      subject { dbo }

      it { should respond_to :name }
      it { should respond_to :db_object_id }
      it { should respond_to :to_sym }


      describe '#name' do
        it "equals to the object name passed in the initializer" do
          expect(dbo.name).to eq 'PK_REP_CODE'
        end
      end


      describe '#db_object_id' do
        it "converts a database object name to downcase symbol" do
          expect(DatabaseObject.new(name: 'PK_REP_CODE').db_object_id).to be :pk_rep_code
          expect(DatabaseObject.new(name: :Reps).db_object_id).to be :reps
          expect(DatabaseObject.new(name: 'dBo.master_Accounts').db_object_id).to be :dbo_master_accounts
          expect(DatabaseObject.new(name: 'ref.contract_Types').db_object_id).to be :ref_contract_types
        end
      end


      describe '#to_sym' do
        it "is alias of db_object_id" do
          expect(dbo.to_sym).to be dbo.db_object_id
          expect(dbo.to_sym).to_not be nil
          expect(DatabaseObject.new(name: 'dBo.master_Accounts').to_sym).to be :dbo_master_accounts
          expect(DatabaseObject.new(name: 'ref.contract_Types').to_sym).to be :ref_contract_types
        end
      end
    end
  end
end
