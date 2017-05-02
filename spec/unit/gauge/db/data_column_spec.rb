# Eithery Lab, 2017
# Gauge::DB::DataColumn specs

require 'spec_helper'

module Gauge
  module DB
    describe DataColumn do
      let(:column_options) { double('sequel') }
      let(:column) { DataColumn.new(name: 'REP_CODE', options: column_options) }

      subject { column }

      it { expect(DataColumn).to be < DatabaseObject }

      it { should respond_to :column_id }
      it { should respond_to :data_type }
      it { should respond_to :allow_null? }
      it { should respond_to :length }
      it { should respond_to :default_value }
      it { should respond_to :to_sym }


      describe '#column_id' do
        it "returns a data column name converted to a symbol" do
          {
            'id' => :id,
            'account_number' => :account_number,
            'SOURCE_FIRM' => :source_firm,
            :Rep_Code => :rep_code
          }
          .each do |column_name, expected_symbol|
            expect(DataColumn.new(name: column_name).to_sym).to eq expected_symbol
          end
        end
      end


      describe '#to_sym' do
        it "is alias of 'column_id'" do
          expect(column.to_sym).to be column.column_id
          expect(column.to_sym).to_not be nil
        end
      end


      describe '#data_type' do
        it "gets an actual data type from Sequel column options" do
          expect(column_options).to receive(:[]).with(:db_type).and_return('nvarchar')
          column.data_type
        end

        it "represents a column data type as a symbol" do
          column_options.stub(:[]).with(:db_type).and_return('bigint')
          expect(column.data_type).to be :bigint
        end
      end


      describe '#allow_null?' do
        it "gets an actual column nullability from Sequel column options" do
          expect(column_options).to receive(:[]).with(:allow_null).and_return(true)
          expect(column.allow_null?).to be true
        end
      end


      describe '#length' do
        it "gets an actual column length from Sequel column options" do
          expect(column_options).to receive(:[]).with(:max_chars).and_return(10)
          expect(column.length).to eq 10
        end
      end


      describe '#default_value' do
        it "gets an actual column default value from Sequel column options" do
          expect(column_options).to receive(:[]).with(:ruby_default).once.and_return(nil)
          expect(column_options).to receive(:[]).with(:default).once.and_return(1)
          expect(column.default_value).to eq 1
        end

        context "when an actual default value is Sequel CURRENT_TIMESTAMP constant" do
          it "determines a column default value as a current timestamp" do
            column_options.stub(:[]).with(:ruby_default).and_return(Sequel::SQL::Constant.new(:CURRENT_TIMESTAMP))
            expect(column.default_value).to be :current_timestamp
          end
        end

        context "when an actual default value is wrapped by parentheses" do
          it "removes parentheses from default value" do
            column_options.stub(:[]).with(:ruby_default).and_return(nil)
            column_options.stub(:[]).with(:default).and_return('(host_name())')
            expect(column.default_value).to eq 'host_name()'
          end
        end
      end
    end
  end
end
