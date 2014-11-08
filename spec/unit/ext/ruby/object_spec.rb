# Eithery Lab., 2014.
# Object extension specs.
# Covers some monkey patches for Object class.
require 'spec_helper'

describe Object do
  it { should respond_to :database, :table }


  describe '#database' do
    it "Delegates creating new database schema to metadata factory" do
      Gauge::Schema::MetadataFactory.should_receive(:define_database).with(:rep_profile, hash_including(:sql_name))
      database :rep_profile, sql_name: 'RepProfile'
    end
  end


  describe '#table' do
  end
end
