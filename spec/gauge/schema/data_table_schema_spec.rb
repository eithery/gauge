# Eithery Lab., 2014.
# Gauge::Schema::DataTableSchema specs.
require 'spec_helper'

module Gauge
  module Schema
    describe DataTableSchema do
      let(:mock_file) do
        File.stub(:exists?).and_return(true)
        File.stub(:open)
      end

      let(:table) { DataTableSchema.new(mock_file) }
      subject { table }

      it { should respond_to :sql_schema, :columns }
      it { should respond_to :database_name, :table_name }
      it { should respond_to :to_key }

      describe '#initialize' do
        it "raises an error if the specified file is not found" do
          expect { DataTableSchema.new('unknown_schema') }.to raise_error(ArgumentError, /file '.*' not found/)
        end
      end


      describe '#sql_schema' do
      end


      describe '#columns' do
      end


      describe '#database_name' do
      end


      describe '#table_name' do
      end


      describe '#to_key' do
      end
    end
  end
end
