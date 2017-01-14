# Eithery Lab, 2017
# Object extensions specs

require 'spec_helper'

describe Object do
  let(:db_schema) do
    schema = double('db_schema')
    allow(Gauge::Schema::DatabaseSchema).to receive(:current).and_return(schema)
    schema
  end


  it { expect(subject.respond_to?(:table, true)).to be true }
  it { expect(subject.respond_to?(:view, true)).to be true }


  describe '#table' do
    it "delegates creaing a data table schema to the database schema instance" do
      table_columns = ->{}

      expect(db_schema).to receive(:define_table) do |table, &block|
        expect(table).to be :primary_reps
        expect(table_columns).to be block
      end

      table :primary_reps, &table_columns
    end
  end


  describe '#view' do
    it "delegates creating a data view schema to the database schema instance" do
      view_columns = ->{}

      expect(db_schema).to receive(:define_view) do |view, &block|
        expect(view).to be :trades
        expect(view_columns).to be block
      end

      view :trades, &view_columns
    end
  end
end
