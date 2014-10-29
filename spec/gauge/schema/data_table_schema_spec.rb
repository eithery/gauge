# Eithery Lab., 2014.
# Gauge::Schema::DataTableSchema specs.
require 'spec_helper'

module Gauge
  module Schema
    describe DataTableSchema do
      let(:table_schema) do
        File.stub(:exists?).and_return(true)
        File.stub(:open) do |file, mode, &block|
          block.call(@xml)
        end
        DataTableSchema.new(@table_schema_file)
      end

      let(:xml_with_custom_sql_schema) { %{<table name="master_accounts" schema="ref"/>} }
      let(:xml_with_default_sql_schema) do
        %{
          <table name="source_firms">
            <columns>
              <col name="name" length="256" required="true"/>
              <col name="display_name" length="256" required="true"/>
            </columns>
          </table>
        }
      end

      before do
        @table_schema_file = 'master_accounts.db.xml'
        @xml = xml_with_default_sql_schema
      end


      subject { table_schema }
      it { should respond_to :sql_schema, :columns }
      it { should respond_to :database_name, :table_name, :local_name }
      it { should respond_to :to_key }


      describe '#initialize' do
        it "raises an error if the specified file is not found" do
          expect { DataTableSchema.new('unknown_schema') }.to raise_error(ArgumentError, /file '.*' is not found/)
        end
      end


      describe '#sql_schema' do
        subject { table_schema.sql_schema }

        context "when data table is defined in default SQL schema" do
          it { should == :dbo }
        end

        context "when data table is defined in custom SQL schema" do
          before { @xml = xml_with_custom_sql_schema }
          it { should == :ref }
        end
      end


      describe '#columns' do
        context "when id column is taken by convention" do
          it "contains the number of columns defined in metadata + 1" do
            table_schema.should have(3).columns
            table_schema.should contain_column(:name)
            table_schema.should contain_column(:display_name)
            table_schema.should_not contain_column(:rep_code)
          end

          it "contains 'id' data column" do
            table_schema.should contain_column(:id)
          end
        end

        context "when id column is defined in metadata" do
          before do
            @xml = %{
              <table name="source_firms">
                <columns>
                  <col name="source_firm_id" id="true"/>
                  <col name="name" length="256" required="true"/>
                </columns>
              </table>
            }
          end

          it "contains exact number of columns defined in metadata" do
            table_schema.should have(2).columns
            table_schema.should contain_column :name
            table_schema.should_not contain_column :display_name
          end

          it "contains the data column defined as id" do
            table_schema.should contain_column :source_firm_id
            table_schema.should_not contain_column :id
          end
        end

        context "when table definition contains timestamps" do
          context "in default case" do
            before do
              @xml = %{
                <table name="source_firms">
                  <columns><timestamps/></columns>
                </table>
              }
            end

            it "should contain 4 timestamp columns and id" do
              table_schema.should have(6).columns
              table_schema.should contain_column :created
              table_schema.should contain_column :created_by
              table_schema.should contain_column :modified
              table_schema.should contain_column :modified_by
              table_schema.should contain_column :version
            end
          end

          context "in camel case" do
            before do
              @xml = %{
                <table name="source_firms">
                  <columns><timestamps case="camel"/></columns>
                </table>
              }
            end

            it "should contain 4 timestamp columns named in camel case and id" do
              table_schema.should have(6).columns
              table_schema.should contain_column :created
              table_schema.should contain_column :createdBy
              table_schema.should contain_column :modified
              table_schema.should contain_column :modifiedBy
              table_schema.should contain_column :version
            end
          end
        end

        context "when no columns specified in metadata" do
          before do
            @xml = %{ <table name="source_firms"><columns/></table> }
          end
          it "contains only one 'id' data column" do
            table_schema.should have(1).column
            table_schema.should contain_column(:id)
          end
        end
      end


      describe '#contains?' do
        context "when the column defined in table definition" do
          specify { table_schema.contains?(:name).should be true }
          specify { table_schema.contains?('name').should be true }
        end

        context "when the column is not defined in table definition" do
          specify { table_schema.contains?(:rep_code).should be false }
          specify { table_schema.contains?('rep_code').should be false }
        end
      end


      describe '#database_name' do
        before { @table_schema_file = 'e:/databases/package_me/tables/main/accounts/master_accounts.db.xml' }
        it "equivalent to the name of folder one level up from 'tables'" do
          table_schema.database_name.should == 'package_me'
        end
      end


      describe '#table_name' do
        subject { table_schema.table_name }

        context "when data table is defined in default SQL schema" do
          it { should == '[dbo].[source_firms]' }
        end

        context "when data table is defined in custom SQL schema" do
          before { @xml = xml_with_custom_sql_schema }
          it { should == '[ref].[master_accounts]' }
        end
      end


      describe '#local_name' do
        subject { table_schema.local_name }

        context "when data table is defined in default SQL schema" do
          it { should == 'source_firms' }
        end

        context "when data table is defined in custom SQL schema" do
          before { @xml = xml_with_custom_sql_schema }
          it { should == 'master_accounts' }
        end
      end


      describe '#to_key' do
        context "for default SQL schema" do
          it "returns the local table name converted to symbol" do
            table_schema.to_key.should == :source_firms
          end
        end

        context "for custom SQL schema" do
          before { @xml = xml_with_custom_sql_schema }
          it "concatenates SQL schema and local table name" do
            table_schema.to_key.should == :ref_master_accounts
          end
        end
      end
    end
  end
end
