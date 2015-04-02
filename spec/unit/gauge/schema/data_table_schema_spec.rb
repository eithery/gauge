# Eithery Lab., 2015.
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
          col :source_firm_id, id: true
        end
      end
      let(:table_schema) { dbo_table_schema }

      subject { dbo_table_schema }

      it { should respond_to :table_name, :local_name }
      it { should respond_to :sql_schema, :database_schema }
      it { should respond_to :object_name, :sql_name }
      it { should respond_to :reference_table? }
      it { should respond_to :columns }
      it { should respond_to :primary_key }
      it { should respond_to :contains? }
      it { should respond_to :col, :timestamps }
      it { should respond_to :index }
      it { should respond_to :to_sym }


      describe '#table_name' do
        context "when data table is defined in default SQL schema" do
          specify { dbo_table_schema.table_name.should == 'dbo.master_accounts' }
        end

        context "when data table is defined in custom SQL schema" do
          specify { ref_table_schema.table_name.should == 'ref.source_firms' }
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


      describe '#object_name' do
        specify { table_schema.object_name.should == "Data table" }
      end


      describe '#sql_schema' do
        context "when data table is defined in default SQL schema" do
          specify { dbo_table_schema.sql_schema.should == :dbo }
        end

        context "when data table is defined in custom SQL schema" do
          specify { ref_table_schema.sql_schema.should == :ref }
        end
      end


      describe '#sql_name' do
        specify { table_schema.sql_name.should == table_schema.table_name }
      end


      describe '#database_schema' do
        before { @database = DatabaseSchema.new(:test_db) }

        context "when database schema is passed in constructor args" do
          before { @table_schema = DataTableSchema.new(:master_accounts, database: @database)}
          specify { @table_schema.database_schema.should == @database }
        end

        context "when no database schema passed in constructors args" do
          before { @table_schema = DataTableSchema.new(:master_accounts) }
          specify { @table_schema.database_schema.should be_nil }
        end
      end


      describe '#reference_table?' do
        context "when data table represents a reference_table" do
          context "defined explicitly" do
            before { @table_schema = DataTableSchema.new(:activation_reasons, type: :reference) }
            specify { @table_schema.should be_reference_table }
          end

          context "defined based on the table name" do
            before { @table_schema = DataTableSchema.new(:risk_tolerance, sql_schema: :ref) }
            specify { @table_schema.should be_reference_table }
          end
        end

        context "when data table is not a reference_table" do
          before { @table_schema = DataTableSchema.new(:master_accounts) }
          specify { @table_schema.should_not be_reference_table }
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


      describe '#to_sym' do
        context "for default SQL schema" do
          it "returns the local table name concatenated with 'dbo' and converted to symbol" do
            dbo_table_schema.to_sym.should == :dbo_master_accounts
          end
        end

        context "for custom SQL schema" do
          it "concatenates SQL schema and local table name" do
            ref_table_schema.to_sym.should == :ref_source_firms
          end
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
          before do
            @table_with_id = DataTableSchema.new(:carriers) do
              col :carrier_id, id: true
              col :code
            end
          end
          it "contains exact number of columns defined in metadata" do
            @table_with_id.should have(2).columns
            @table_with_id.should contain_column :code
            @table_with_id.should_not contain_column :display_name
          end

          it "contains the data column defined as id" do
            @table_with_id.should contain_column :carrier_id
            @table_with_id.should_not contain_column :id
          end
        end

        context "when table definition contains timestamps" do
          context "in default case" do
            before do
              @table_with_timestamps = DataTableSchema.new(:customers) { timestamps dates: :short }
            end

            it "should contain 4 timestamp columns and id" do
              @table_with_timestamps.should have(6).columns
              @table_with_timestamps.should contain_column :created
              @table_with_timestamps.should contain_column :created_by
              @table_with_timestamps.should contain_column :modified
              @table_with_timestamps.should contain_column :modified_by
              @table_with_timestamps.should contain_column :version
              @table_with_timestamps.should contain_column :id
            end
          end

          context "in camel case" do
            before do
              @table_with_timestamps = DataTableSchema.new(:customers) do
                timestamps naming: :camel, dates: :short
              end
            end
            it "should contain 4 timestamp columns named in camel case and id" do
              @table_with_timestamps.should have(6).columns
              @table_with_timestamps.should contain_column :created
              @table_with_timestamps.should contain_column :createdBy
              @table_with_timestamps.should contain_column :modified
              @table_with_timestamps.should contain_column :modifiedBy
              @table_with_timestamps.should contain_column :version
              @table_with_timestamps.should contain_column :id
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


      describe '#col' do
        before do
          table_schema
          @column_schema = double('column_schema', table: table_schema)
          @column_schema.stub(in_table: @column_schema)
        end

        it "creates new data column schema" do
          DataColumnSchema.should_receive(:new).with(:office_code, hash_including(type: :string))
            .and_return(@column_schema)
          table_schema.col :office_code, type: :string
        end

        it "adds the new column schema to columns collection" do
          DataColumnSchema.stub(:new).and_return(@column_schema)
          expect { table_schema.col :office_code }.to change { table_schema.columns.count }.by(1)
          table_schema.columns.should include(@column_schema)
        end

        it "sets data table attribute for newly created data column" do
          table_schema.col :office_code, type: :string
          last_column_should_have_table

          table_schema.col :ref => 'ref.risk_tolerance'
          last_column_should_have_table

          table_schema.col :ref => :investment_time_horizon, schema: :ref
          last_column_should_have_table
        end
      end


      describe '#timestamps' do
        before { table_schema }

        it "creates 5 new data column schema instances" do
          @column_schema = DataColumnSchema.new(:office_code, table: 'master_accounts')
          DataColumnSchema.should_receive(:new).at_least(5).times.and_return(@column_schema)
          table_schema.timestamps
        end

        it "adds 5 new column schema instances to columns collection" do
          expect { table_schema.timestamps }.to change { table_schema.columns.count }.by(5)
        end

        context "with default date naming convention" do
          specify { columns_should_be_added(:created_at, :modified_at) { table_schema.timestamps }}
        end

        context "with 'short' date naming convention" do
          specify { columns_should_be_added(:created, :modified) { table_schema.timestamps dates: :short }}
        end

        context "with default naming convention for string columns" do
          specify { columns_should_be_added(:created_by, :modified_by) { table_schema.timestamps }}
        end

        context "with 'camel' column naming convention for string columns" do
          specify { columns_should_be_added(:createdBy, :modifiedBy) { table_schema.timestamps naming: :camel }}
        end
      end


      describe '#primary_key' do
        subject { table_schema.primary_key }

        it { should_not be nil }
        it { should be_a DB::Constraints::PrimaryKeyConstraint }

        it "always returns the same object instance" do
          key = table_schema.primary_key
          table_schema.primary_key.should be_equal(key)
          key.should be_equal(subject)
        end

        context "when the primary key is defined by convention" do
          its(:name) { should == 'pk_dbo_master_accounts' }
          its(:table) { should == table_schema.to_sym }
          specify { table_schema.primary_key.columns.should have(1).column }
          its(:columns) { should include(:id) }

          it { should be_clustered }
          it { should_not be_composite }
        end

        context "when the primary key is defined through :id attribute" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code, id: true
              col :rep_name
            end
          end
          subject { @reps_table.primary_key }

          its(:name) { should == 'pk_bnr_reps' }
          its(:table) { should == @reps_table.to_sym }
          specify { @reps_table.primary_key.columns.should have(1).column }
          its(:columns) { should include(:rep_code) }

          it { should be_clustered }
          it { should_not be_composite }
        end

        context "when the primary key is not clustered" do
          before do
            @source_firms_table = DataTableSchema.new(:source_firms, sql_schema: :ref) do
              col :code, len: 10, business_id: true
              col :source_name
            end
          end
          subject { @source_firms_table.primary_key }

          its(:name) { should == 'pk_ref_source_firms' }
          its(:table) { should == @source_firms_table.to_sym }
          specify { @source_firms_table.primary_key.columns.should have(1).column }
          its(:columns) { should include(:id) }

          it { should_not be_clustered }
          it { should_not be_composite }
        end

        context "when the primary key is composite" do
          before do
            @account_owners_table = DataTableSchema.new(:account_owners) do
              col :master_account_id, :ref => :br_master_account, id: true
              col :natural_owner_id, :ref => :br_natural_owner, id: true
              col :ordinal, type: :byte, required: true, check: '> 0'
            end
          end
          subject { @account_owners_table.primary_key }

          its(:name) { should == 'pk_dbo_account_owners' }
          its(:table) { should == @account_owners_table.to_sym }
          specify { @account_owners_table.primary_key.columns.should have(2).columns }
          its(:columns) { should include(:master_account_id, :natural_owner_id) }

          it { should be_clustered }
          it { should be_composite }
        end
      end

  private

      def last_column_should_have_table
        table_schema.columns.last.table.should be_equal(table_schema)
      end


      def columns_should_be_added(*columns)
        columns.each { |col| table_schema.should_not contain_column(col) }
        yield
        columns.each { |col| table_schema.should contain_column(col) }
      end
    end
  end
end
