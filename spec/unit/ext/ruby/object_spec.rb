# Eithery Lab., 2017
# Object extension specs

require 'spec_helper'

describe Object do
  it { expect(subject.respond_to?(:table, true)).to be true }


  describe '#table' do
    it "Delegates creaing a new data table schema to metadata repo" do
      table_columns = ->{}

      expect(Gauge::Schema::Repo).to receive(:define_table) do |table, &block|
        expect(table).to be :primary_reps
        expect(table_columns).to be block
      end

      table :primary_reps, &table_columns
    end
  end
end
