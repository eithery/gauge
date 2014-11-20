# Eithery Lab., 2014.
# Object extension specs.
# Covers some monkey patches for Object class.
require 'spec_helper'

describe Object do
  it { should respond_to :database, :table }


  describe '#database' do
    it "Delegates creating a new database schema to metadata repo" do
      Gauge::Schema::Repo.should_receive(:define_database).with(:rep_profile, hash_including(:sql_name))
      database :rep_profile, sql_name: 'RepProfile'
    end
  end


  describe '#table' do
    it "Delegates creaing new data table schema to metadata repo" do
      Gauge::Schema::Repo.should_receive(:define_table).with(:primary_reps)
      table :primary_reps do
        col :first_name
        col :last_name, required: true
      end
    end
  end
end
