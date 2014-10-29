# Eithery Lab., 2014.
# Gauge::Schema::DatabaseSchema specs.
require 'spec_helper'

module Gauge
  module Schema
    describe DatabaseSchema do
      let(:db_schema) do
        File.stub(:exists?).and_return(true)
        DatabaseSchema.new('rep_profile_db', '.')
      end
      subject { db_schema }

      it { should respond_to :database_name, :tables }


      describe '#initialize' do
        it "raises an error when the database metadata does not exist" do
          expect { DatabaseSchema.new('missing_db_name', '.') }.to raise_error(/metadata for '.*' is not defined/i)
        end
      end


      describe '#database_name' do
        subject { db_schema.database_name }
        it { should == 'rep_profile_db'}
      end


      describe '#tables' do
        before do
          Dir.stub(:[]).and_return(['accounts.db.xml', 'reps.db.xml'])
          schema = {
          accounts: %{
            <table name="accounts">
              <columns><col name="name" length="256" required="true"/></columns>
            </table>
          },
          reps: %{
            <table name="reps" schema="ref">
              <columns>
                <col name="code" length="256" required="true"/>
                <col name="name" length="256"/>
              </columns>
            </table>
          }}
          File.stub(:open) do |file, mode, &block|
            table_name = file.sub('.db.xml', '')
            block.call(schema[table_name.to_sym])
          end
        end
        subject { db_schema.tables }

        it { should_not be_empty }
        it { should have(2).tables }
        specify { db_schema.tables.keys.should == [:accounts, :ref_reps] }

        it "contains data table schema definitions" do
          accounts = db_schema.tables[:accounts]
          accounts.table_name.should == '[dbo].[accounts]'
          accounts.sql_schema.should == :dbo
          accounts.columns.should have(2).column_definitions

          reps = db_schema.tables[:ref_reps]
          reps.table_name.should == '[ref].[reps]'
          reps.sql_schema.should == :ref
          reps.columns.should have(3).column_definitions
        end
      end
    end
  end
end
