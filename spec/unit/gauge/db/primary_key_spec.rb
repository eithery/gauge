# Eithery Lab., 2014.
# Class Gauge::DB::PrimaryKey specs.

require 'spec_helper'

module Gauge
  module DB
    describe PrimaryKey do
      let(:key) { PrimaryKey.new('pk_primary_reps', 'br.primary_reps', :rep_code) }
      subject { key }

      it { should respond_to :name }
      it { should respond_to :table }
      it { should respond_to :columns }
      it { should respond_to :clustered?, :composite? }


      describe '#name' do
        it "equals to the key name passed in the initializer" do
          key.name.should == 'pk_primary_reps'
        end
      end


      describe '#table' do
        it "equals to the table name passed in the initializer" do
          key.table.should == 'br.primary_reps'
        end
      end


      describe '#columns' do
        specify { key.columns.should include(:rep_code) }
      end


      describe '#clustered?' do
        context "when not defined explicitly in the initializer" do
          it { should be true }
        end
      end


      describe '#composite?' do
      end
    end
  end
end
