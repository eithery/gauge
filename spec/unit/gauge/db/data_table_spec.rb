# Eithery Lab., 2014.
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
