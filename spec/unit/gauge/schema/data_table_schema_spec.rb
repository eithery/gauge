# Eithery Lab., 2014.
# Gauge::Schema::DataTableSchema specs.
require 'spec_helper'

module Gauge
  module Schema
    describe DataTableSchema do
      let(:dbo_table_schema) do
        DataTableSchema.new(:master_accounts) do
          col :account_number
          col :total_amount
        end
      end
      let(:ref_table_schema) do
        DataTableSchema.new(:source_firms, sql_schema: :ref) do
          col :source_firm_id
        end
      end
      let(:table_schema) { dbo_table_schema }
      let(:table_with_id) do
        DataTableSchema.new(:carriers) do
          col :carrier_id, id: true
          col :code
        end
      end

      subject { dbo_table_schema }

      it { should respond_to :table_name, :local_name }
      it { should respond_to :sql_schema, :columns }
      it { should respond_to :to_key, :contains? }
      it { should respond_to :col, :timestamps }


      describe '#table_name' do
        context "when data table is defined in default SQL schema" do
          specify { dbo_table_schema.table_name.should == '[dbo].[master_accounts]' }
        end

        context "when data table is defined in custom SQL schema" do
          specify { ref_table_schema.table_name.should == '[ref].[source_firms]' }
        end
      end



      describe '#sql_schema' do
        context "when data table is defined in default SQL schema" do
          specify { dbo_table_schema.sql_schema.should == :dbo }
        end

        context "when data table is defined in custom SQL schema" do
          specify { ref_table_schema.sql_schema.should == :ref }
        end
      end


      describe '#local_name' do
        context "when data table is defined in default SQL schema" do
          specify { dbo_table_schema.local_name.should == 'master_accounts' }
        end

        context "when data table is defined in custom SQL schema" do
          specify { ref_table_schema.local_name.should == 'source_firms' }
        end
      end


      describe '#to_key' do
        context "for default SQL schema" do
          it "returns the local table name concatenated with 'dbo' and converted to symbol" do
            dbo_table_schema.to_key.should == :dbo_master_accounts
          end
        end

        context "for custom SQL schema" do
          it "concatenates SQL schema and local table name" do
            ref_table_schema.to_key.should == :ref_source_firms
          end
        end
      end


      describe '#contains?' do
        context "when the column defined in table definition" do
          specify { table_schema.contains?(:account_number).should be true }
          specify { table_schema.contains?('account_number').should be true }
        end

        context "when the column is not defined in table definition" do
          specify { table_schema.contains?(:rep_code).should be false }
          specify { table_schema.contains?('rep_code').should be false }
        end
      end


      describe '#columns' do
        context "when id column is taken by convention" do
          it "contains the number of columns defined in metadata + 1" do
            table_schema.should have(3).columns
            table_schema.should contain_column(:account_number)
            table_schema.should contain_column(:total_amount)
            table_schema.should_not contain_column(:rep_code)
          end

          it "contains 'id' data column" do
            table_schema.should contain_column(:id)
          end
        end

        context "when id column is defined in metadata" do
          it "contains exact number of columns defined in metadata" do
            table_with_id.should have(2).columns
            table_with_id.should contain_column :code
            table_with_id.should_not contain_column :display_name
          end

          it "contains the data column defined as id" do
            table_with_id.should contain_column :carrier_id
            table_with_id.should_not contain_column :id
          end
        end

        context "when table definition contains timestamps" do
          context "in default case" do
            before do
              @table_with_timestamps = DataTableSchema.new(:customers) { timestamps }
            end

            it "should contain 4 timestamp columns and id" do
              @table_with_timestamps.should have(6).columns
              @table_with_timestamps.should contain_column :created
              @table_with_timestamps.should contain_column :created_by
              @table_with_timestamps.should contain_column :modified
              @table_with_timestamps.should contain_column :modified_by
              @table_with_timestamps.should contain_column :version
            end
          end

          context "in camel case" do
            before do
              @table_with_timestamps = DataTableSchema.new(:customers) do
                timestamps casing: :camel
              end
            end
            it "should contain 4 timestamp columns named in camel case and id" do
              @table_with_timestamps.should have(6).columns
              @table_with_timestamps.should contain_column :created
              @table_with_timestamps.should contain_column :createdBy
              @table_with_timestamps.should contain_column :modified
              @table_with_timestamps.should contain_column :modifiedBy
              @table_with_timestamps.should contain_column :version
            end
          end
        end

        context "when no columns specified in metadata" do
          before { @empty_table_schema = DataTableSchema.new(:customers) }
          it "contains only one 'id' data column" do
            @empty_table_schema.should have(1).column
            @empty_table_schema.should contain_column(:id)
          end
        end
      end
    end
  end
end
