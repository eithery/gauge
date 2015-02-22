# Eithery Lab., 2015.
# Class Gauge::DB::DatabaseObject specs.

require 'spec_helper'

module Gauge
  module DB
    describe DatabaseObject do
      let(:db_object) { DatabaseObject.new('PK_Rep_Code') }
      subject { db_object }

      it { should respond_to :name }


      describe '#name' do
        it "equals to the object name in downcase passed in the initializer" do
          db_object.name.should == 'pk_rep_code'
        end
      end
    end
  end
end
