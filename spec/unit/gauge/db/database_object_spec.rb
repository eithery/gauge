# Eithery Lab., 2015.
# Class Gauge::DB::DatabaseObject specs.

require 'spec_helper'

module Gauge
  module DB
    describe DatabaseObject do
      let(:dbo_name) { 'PK_REP_CODE' }
      let(:dbo) { DatabaseObject.new(dbo_name) }

      it_should_behave_like "any database object"

      subject { dbo }
      it { should respond_to :to_sym }


      describe '#to_sym' do
        it "converts the database object name to symbol in downcase" do
          DatabaseObject.new(dbo_name).to_sym.should == :pk_rep_code
          DatabaseObject.new(:Reps).to_sym.should == :reps
          DatabaseObject.new('dBo.master_Accounts').to_sym.should == :dbo_master_accounts
        end
      end
    end
  end
end
