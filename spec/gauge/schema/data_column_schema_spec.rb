# Eithery Lab., 2014.
# Gauge::Schema::DataColumnSchema specs.
require 'spec_helper'

module Gauge
  module Schema
    describe DataColumnSchema do
      let(:table_name) { 'my_sample_table' }
      let(:column) { DataColumnSchema.new(table_name, name: 'rep_code', type: :string, required: true) }
      subject { column }

      it { should respond_to :table_name, :column_name, :column_type, :data_type }
      it { should respond_to :allow_null? }
      it { should respond_to :to_key }

      describe '#table_name' do
        it "returns the table name defined in initializer" do
          column.table_name.should == table_name
        end
      end

      describe '#column_name' do
      end

      describe '#column_type' do
      end

      describe '#data_type' do
      end

      describe '#allow_null?' do
      end

      describe '#to_key' do
      end
    end
  end
end
