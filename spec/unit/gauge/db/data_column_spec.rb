# Eithery Lab., 2015.
# Class Gauge::DB::DataColumn specs.
require 'spec_helper'

module Gauge
  module DB
    describe DataColumn do
      let(:sequel) { double('sequel') }
      let(:column) { DataColumn.new(sequel) }
      subject { column }

      it { should respond_to :data_type }
      it { should respond_to :allow_null? }
      it { should respond_to :length }
      it { should respond_to :default_value }


      describe '#data_type' do
        it "retrieves the actual data type from Sequel" do
          sequel.should_receive(:[]).with(:db_type).and_return('nvarchar')
          column.data_type
        end

        it "represents a column data type as symbol" do
          sequel.stub(:[]).with(:db_type).and_return('bigint')
          column.data_type.should == :bigint
        end
      end


      describe '#allow_null?' do
        it "retrieves the actual column nullability value from Sequel" do
          sequel.should_receive(:[]).with(:allow_null).and_return(true)
          column.allow_null?.should be true
        end
      end


      describe '#length' do
        it "retrieves the actual column length from Sequel" do
          sequel.should_receive(:[]).with(:max_chars).and_return(10)
          column.length.should == 10
        end
      end


      describe '#default_value' do
        it "retrieves the actual column default value from Sequel" do
          sequel.should_receive(:[]).with(:ruby_default).once.and_return(nil)
          sequel.should_receive(:[]).with(:default).once.and_return(1)
          column.default_value.should == 1
        end

        context "when the actual default value is CURRENT_TIMESTAMP constant" do
          before { sequel.stub(:[]).with(:ruby_default).and_return(Sequel::SQL::Constant.new(:CURRENT_TIMESTAMP)) }
          it "converts Sequel constant to SQL function" do
            column.default_value.should == :current_timestamp
          end
        end

        context "when the actual default value is wrapped by parentheses" do
          before do
            sequel.stub(:[]).with(:ruby_default).and_return(nil)
            sequel.stub(:[]).with(:default).and_return('(host_name())')
          end
          it "removes parentheses from default value" do
            column.default_value.should == 'host_name()'
          end
        end
      end
    end
  end
end
