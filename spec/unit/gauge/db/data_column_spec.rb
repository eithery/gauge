# Eithery Lab, 2017
# Gauge::DB::DataColumn specs

require 'spec_helper'

module Gauge
  module DB
    describe DataColumn do
      let(:sequel_column_options) { double('sequel') }
      let(:column) { DataColumn.new('REP_CODE', sequel_column_options) }
      let(:dbo) { column }
      subject { column }


      it { expect(DataColumn).to be < DatabaseObject }

      it { should respond_to :data_type }
      it { should respond_to :allow_null? }
      it { should respond_to :length }
      it { should respond_to :default_value }
      it { should respond_to :to_sym }


      describe '#data_type' do
        it "retrieves an actual data type from Sequel column options" do
          expect(sequel_column_options).to receive(:[]).with(:db_type).and_return('nvarchar')
          column.data_type
        end

        it "represents a column data type as symbol" do
          sequel_column_options.stub(:[]).with(:db_type).and_return('bigint')
          expect(column.data_type).to be :bigint
        end
      end


      describe '#allow_null?' do
        it "retrieves an actual column nullability value from Sequel column options" do
          expect(sequel_column_options).to receive(:[]).with(:allow_null).and_return(true)
          expect(column.allow_null?).to be true
        end
      end


      describe '#length' do
        it "retrieves an actual column length from Sequel column options" do
          expect(sequel_column_options).to receive(:[]).with(:max_chars).and_return(10)
          expect(column.length).to eq 10
        end
      end


      describe '#default_value' do
        it "retrieves an actual column default value from Sequel column options" do
          expect(sequel_column_options).to receive(:[]).with(:ruby_default).once.and_return(nil)
          expect(sequel_column_options).to receive(:[]).with(:default).once.and_return(1)
          expect(column.default_value).to eq 1
        end

        context "when an actual default value is Sequel CURRENT_TIMESTAMP constant" do
          it "determines a column default value as current timestamp" do
            sequel_column_options.stub(:[]).with(:ruby_default).and_return(Sequel::SQL::Constant.new(:CURRENT_TIMESTAMP))
            expect(column.default_value).to be :current_timestamp
          end
        end

        context "when an actual default value is wrapped by parentheses" do
          it "removes parentheses from default value" do
            sequel_column_options.stub(:[]).with(:ruby_default).and_return(nil)
            sequel_column_options.stub(:[]).with(:default).and_return('(host_name())')

            expect(column.default_value).to eq 'host_name()'
          end
        end
      end


      describe '#to_sym' do
        it "returns a data column name converted to a symbol" do
          {
            'id' => :id,
            'account_number' => :account_number,
            'SOURCE_FIRM' => :source_firm,
            :Rep_Code => :rep_code
          }
          .each do |name, expected_symbol|
            expect(DataColumn.new(name).to_sym).to eq expected_symbol
          end
        end
      end
    end
  end
end
