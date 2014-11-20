# Eithery Lab., 2014.
# Gauge::Schema::DatabaseSchema specs.
require 'spec_helper'

module Gauge
  module Schema
    describe DatabaseSchema do
      let(:db_schema) { DatabaseSchema.new(:rep_profile, sql_name: 'RepProfile_DB') }
      subject { db_schema }

      it { should respond_to :database_name, :sql_name }
      it { should respond_to :database_schema }
      it { should respond_to :tables, :to_key }


      describe '#database_name' do
        specify { db_schema.database_name.should == 'rep_profile' }
      end


      describe '#sql_name' do
        context "when physical database name is same with the logical one" do
          before { @db_schema = DatabaseSchema.new(:rep_profile) }

          specify { @db_schema.sql_name.should == 'rep_profile' }
          specify { @db_schema.sql_name.should == @db_schema.database_name }
        end

        context "when physical database name differs from the logical one and specified explicitly" do
          specify { db_schema.sql_name.should == 'RepProfile_DB' }
          specify { db_schema.sql_name.should_not == db_schema.database_name }
        end
      end


      describe '#database_schema' do
        specify { db_schema.database_schema.should == db_schema }
      end


      describe '#tables' do
        specify { db_schema.tables.should be_empty }
      end


      describe '#to_key' do
        specify { db_schema.to_key.should == :rep_profile }
      end
    end
  end
end
