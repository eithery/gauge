# Eithery Lab., 2015.
# Class Gauge::DB::DataTable specs.

require 'spec_helper'

module Gauge
  module DB
    describe DataTable do
      let(:dbo_name) { 'PRIMARY_REPS' }
      let(:dbo) { DataTable.new(dbo_name) }
      subject { dbo }

      it_behaves_like "any database object"

      it { should respond_to :columns }
      it { should respond_to :primary_key }
      it { should respond_to :foreign_keys }
      it { should respond_to :unique_constraints }
      it { should respond_to :check_constraints }
      it { should respond_to :indexes }


      describe '#columns' do
      end


      describe '#primary_key' do
        before do
          Sequel::TinyTDS::Database.any_instance.stub(:primary_keys).and_return([
            PrimaryKey.new('pk_accounts', :accounts, :account_number, clustered: true),
            @pk_reps = PrimaryKey.new('pk_primary_reps', :primary_reps, :rep_code),
            PrimaryKey.new('pk_office_types', :office_types, :id, clustered: false)
          ])
          @data_table = DataTable.new(dbo_name)
        end

        it "selects the primary key from the database primary key collection" do
          @data_table.primary_key.should eq(@pk_reps)
        end
      end


      describe '#foreign_keys' do
      end


      describe '#unique_constraints' do
      end


      describe '#check_constraints' do
      end


      describe '#indexes' do
      end
    end
  end
end
