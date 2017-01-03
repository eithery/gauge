# Eithery Lab., 2017
# Object extension specs
# Covers monkey patche for Object class.

require 'spec_helper'

describe Object do
  it { expect(subject.respond_to?(:database, true)).to be true }
  it { expect(subject.respond_to?(:table, true)).to be true }


  describe '#database' do
    it "Delegates creating a new database schema to metadata repo" do
      expect(Gauge::Schema::Repo).to receive(:define_database).with(:rep_profile, sql_name: 'RepProfile')
      database :rep_profile, sql_name: 'RepProfile'
    end
  end


  describe '#table' do
    it "Delegates creaing a new data table schema to metadata repo" do
      expect(Gauge::Schema::Repo).to receive(:define_table).with(:primary_reps)

      table :primary_reps do
        col :first_name
        col :last_name, required: true
      end
    end
  end
end
