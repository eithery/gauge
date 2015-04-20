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
      it { should respond_to :sql_schema, :database_schema, :table_schema }
      it { should respond_to :object_name, :sql_name }
      it { should respond_to :reference_table? }
      it { should respond_to :columns }
      it { should respond_to :primary_key }
      it { should respond_to :foreign_keys }
      it { should respond_to :indexes, :unique_constraints }
      it { should respond_to :contains? }
      it { should respond_to :col, :timestamps }
      it { should respond_to :index, :unique }
      it { should respond_to :to_sym }


      shared_examples_for "index on bnr.reps table" do
        specify { @reps_table.indexes.should have(1).item }
        it { should be_a Gauge::DB::Index }
        its(:table) { should == :bnr_reps }
      end

      shared_examples_for "rep_code index on bnr.reps table" do
        it_behaves_like "index on bnr.reps table"
        its(:name) { should == 'idx_bnr_reps_rep_code' }
        its(:columns) { should have(1).column }
        its(:columns) { should include(:rep_code) }
        it { should_not be_composite }
      end

      shared_examples_for "composite index on rep_code and office_code columns" do
        it_behaves_like "index on bnr.reps table"
        its(:name) { should == 'idx_bnr_reps_rep_code_office_code' }
        its(:columns) { should have(2).columns }
        its(:columns) { should include(:rep_code, :office_code) }
        it { should be_composite }
      end

      shared_examples_for "unique constraint on bnr.reps table" do
        specify { @reps_table.unique_constraints.should have(1).item }
        it { should be_a Gauge::DB::Constraints::UniqueConstraint }
        its(:table) { should == :bnr_reps }
      end

      shared_examples_for "rep_code unique constraint on bnr.reps table" do
        it_behaves_like "unique constraint on bnr.reps table"
        its(:name) { should == 'uc_bnr_reps_rep_code' }
        its(:columns) { should have(1).column }
        its(:columns) { should include(:rep_code) }
        it { should_not be_composite }
      end

      shared_examples_for "composite unique constraint on rep_code and office_code columns" do
        it_behaves_like "unique constraint on bnr.reps table"
        its(:name) { should == 'uc_bnr_reps_rep_code_office_code' }
        its(:columns) { should have(2).columns }
        its(:columns) { should include(:rep_code, :office_code) }
        it { should be_composite }
      end

      shared_examples_for "product_id foreign key on bnr.trades table" do
        specify { @trades_table.foreign_keys.should have(1).item }
        it { should be_a Gauge::DB::Constraints::ForeignKeyConstraint }
        its(:table) { should == :bnr_trades }
        its(:name) { should == 'fk_bnr_trades_bnr_products_product_id' }
        its(:columns) { should have(1).column }
        its(:columns) { should include(:product_id) }
        its(:ref_table) { should == :bnr_products }
        its(:ref_columns) { should have(1).column }
        its(:ref_columns) { should include(:id) }
        it { should_not be_composite }
      end


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


      describe '#table_schema' do
        it "returns self instance" do
          subject.table_schema.should be_equal(subject)
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
        before { table_schema }

        it "creates new data column schema" do
          column = double('column_schema', has_index?: false)
          column.stub(in_table: column)
          DataColumnSchema.should_receive(:new).with(:office_code, hash_including(type: :string)).and_return(column)
          table_schema.col :office_code, type: :string
        end

        it "adds the new column schema to columns collection" do
          expect { table_schema.col :office_code }.to change { table_schema.columns.count }.by(1)
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


      describe '#index' do
        it "creates the new index" do
          Gauge::DB::Index.should_receive(:new).with('idx_dbo_master_accounts_rep_code', 'dbo.master_accounts',
            :rep_code, hash_including(clustered: true))
          table_schema.col :rep_code
          table_schema.index :rep_code, clustered: true
        end

        it "adds the new index to indexes collection" do
          index_stub = double('index')
          Gauge::DB::Index.stub(:new).and_return(index_stub)
          table_schema.col :rep_code
          expect { table_schema.index :rep_code }.to change { table_schema.indexes.count }.by(1)
          table_schema.indexes.should include(index_stub)
        end

        context "when the index includes only one column" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :rep_name
              index :rep_code
            end
          end
          subject { @reps_table.indexes.first }
          it_should_behave_like "rep_code index on bnr.reps table"
          it { should_not be_clustered }
          it { should_not be_unique }
        end

        context "when the index is defined on multiple columns" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :office_code
              index [:rep_code, :office_code]
            end
          end
          subject { @reps_table.indexes.first }
          it_behaves_like "composite index on rep_code and office_code columns"
          it { should_not be_clustered }
          it { should_not be_unique }
        end

        context "when the index is defined as unique" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :office_code
              index [:rep_code, :office_code], unique: true
            end
          end
          subject { @reps_table.indexes.first }
          it_behaves_like "composite index on rep_code and office_code columns"
          it { should_not be_clustered }
          it { should be_unique }
        end

        context "when the index is defined as clustered" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :office_code
              index [:rep_code, :office_code], clustered: true
            end
          end
          subject { @reps_table.indexes.first }
          it_behaves_like "composite index on rep_code and office_code columns"
          it { should be_clustered }
          it { should be_unique }
        end

        context "when the index is defined on missing column" do
          specify do
            expect {
              DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code
                col :rep_name
                index [:rep_code, :office_code]
              end
            }.to raise_error(/missing column 'office_code' in bnr.reps data table/i)
          end
        end
      end


      describe '#unique' do
        it "creates the new unique constraint" do
          Gauge::DB::Constraints::UniqueConstraint.should_receive(:new).with('uc_dbo_master_accounts_rep_code',
            'dbo.master_accounts', :rep_code)
          table_schema.col :rep_code
          table_schema.unique :rep_code
        end

        it "adds the new unique constraint to unique constraints collection" do
          constraint_stub = double('unique_constraint')
          Gauge::DB::Constraints::UniqueConstraint.stub(:new).and_return(constraint_stub)
          table_schema.col :rep_code
          expect { table_schema.unique :rep_code }.to change { table_schema.unique_constraints.count }.by(1)
          table_schema.unique_constraints.should include(constraint_stub)
        end

        context "when the unique constraint includes only one column" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :rep_name
              unique :rep_code
            end
          end
          subject { @reps_table.unique_constraints.first }
          it_should_behave_like "rep_code unique constraint on bnr.reps table"
        end

        context "when the unique constraint is defined on multiple columns" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :office_code
              unique [:rep_code, :office_code]
            end
          end
          subject { @reps_table.unique_constraints.first }
          it_behaves_like "composite unique constraint on rep_code and office_code columns"
        end

        context "when the unique constraint is defined on missing column" do
          specify do
            expect {
              DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code
                col :rep_name
                unique [:rep_code, :office_code]
              end
            }.to raise_error(/missing column 'office_code' in bnr.reps data table/i)
          end
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

        context "when a business key is defined on the table" do
          before do
            @reps_table = DataTableSchema.new(:reps) do
              col :rep_id, id: true
              col :rep_code, business_id: true
            end
          end
          subject { @reps_table.primary_key }
          it { should_not be_clustered }
        end

        context "when a clustered index is defined on the column" do
          before do
            @reps_table = DataTableSchema.new(:reps) do
              col :rep_id, id: true
              col :rep_code, index: { clustered: true }
            end
          end
          subject { @reps_table.primary_key }
          it { should_not be_clustered }
        end

        context "when a composite clustered index is defined on the table" do
          before do
            @fund_accounts_table = DataTableSchema.new(:fund_accounts) do
              col :fund_account_number
              col :cusip, len: 9
              index [:fund_account_number, :cusip], clustered: true
            end
          end
          subject { @fund_accounts_table.primary_key }
          its(:columns) { should include(:id) }
          it { should_not be_clustered }
        end
      end


      describe '#indexes' do
        subject { table_schema.indexes }

        it { should_not be_nil }

        context "when the table does not have indexes" do
          it { should be_empty }
        end

        context "when only one index is defined on the table" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code, index: true
            end
          end
          subject { @reps_table.indexes.first }
          it_should_behave_like "rep_code index on bnr.reps table"
          it { should_not be_clustered }
          it { should_not be_unique }
        end

        context "when multiple indexes are defined on the table" do
          before do
            @trades = DataTableSchema.new(:trades) do
              col :trade_id, index: true
              col :rep_code, index: true
              col :batch_id, index: true
            end
          end

          specify { @trades.indexes.should have(3).items }
          subject { @trades.indexes.last }
          it { should be_a Gauge::DB::Index }
          its(:name) { should == 'idx_dbo_trades_batch_id' }
          its(:table) { should == :dbo_trades }
          its(:columns) { should have(1).column }
          its(:columns) { should include(:batch_id) }
          it { should_not be_composite }
          it { should_not be_clustered }
          it { should_not be_unique }
        end

        context "when unique index is defined on the table" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_id, id: true
              col :rep_code, index: { unique: true }
            end
          end
          subject { @reps_table.indexes.first }
          it_should_behave_like "rep_code index on bnr.reps table"
          it { should_not be_clustered }
          it { should be_unique }
        end

        context "when clustered index is defined on the table" do
          context "as regular index" do
            before do
              @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, index: { clustered: true }
                col :rep_name
              end
            end
            subject { @reps_table.indexes.first }
            it_should_behave_like "rep_code index on bnr.reps table"
            it { should be_clustered }
            it { should be_unique }
          end

          context "as natural business key (using 'business_id')" do
            before do
              @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, business_id: true
                col :rep_name
              end
            end
            subject { @reps_table.indexes.first }
            it_should_behave_like "rep_code index on bnr.reps table"
            it { should be_clustered }
            it { should be_unique }
          end
        end

        context "when composite (multicolumn) index is defined on the table" do
          subject { @reps_table.indexes.first }

          context "and it is regular (nonclustered and not unique)" do
            before do
              @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code]
              end
            end
            it_behaves_like "composite index on rep_code and office_code columns"
            it { should_not be_clustered }
            it { should_not be_unique }
          end

          context "and it is unique" do
            before do
              @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code], unique: true
              end
            end
            it_behaves_like "composite index on rep_code and office_code columns"
            it { should_not be_clustered }
            it { should be_unique }
          end

          context "and it is clustered" do
            before do
              @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code], clustered: true
              end
            it_behaves_like "composite index on rep_code and office_code columns"
            it { should be_clustered }
            it { should be_unique }
            end
          end

          context "and it is clustered but not unique" do
            before do
              @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code], clustered: true, unique: false
              end
            end
            it_behaves_like "composite index on rep_code and office_code columns"
            it { should be_clustered }
            it { should be_unique }
          end

          context "and it is natural business key (using 'business_id')" do
            before do
              @fund_accounts_table = DataTableSchema.new(:fund_accounts) do
                col :fund_account_number, len: 20, business_id: true
                col :cusip, len: 9, business_id: true
              end
            end

            specify { @fund_accounts_table.indexes.should have(1).item }
            subject { @fund_accounts_table.indexes.first }
            it { should be_a Gauge::DB::Index }
            its(:name) { should == 'idx_dbo_fund_accounts_fund_account_number_cusip' }
            its(:table) { should == :dbo_fund_accounts }
            its(:columns) { should have(2).columns }
            its(:columns) { should include(:fund_account_number, :cusip) }
            it { should be_composite }
            it { should be_clustered }
            it { should be_unique }
          end
        end
      end


      describe '#unique_constraints' do
        subject { table_schema.unique_constraints }

        it { should_not be_nil }

        context "when the table does not have unique constraints" do
          it { should be_empty }
        end

        context "when only one unique constraint is defined on the table" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code, unique: true
            end
          end
          subject { @reps_table.unique_constraints.first }
          it_should_behave_like "rep_code unique constraint on bnr.reps table"
        end


        context "when multiple unique constraints are defined on the table" do
          before do
            @trades = DataTableSchema.new(:trades) do
              col :trade_id, unique: true
              col :rep_code, unique: true
              col :batch_id, unique: true
            end
          end

          specify { @trades.unique_constraints.should have(3).items }
          subject { @trades.unique_constraints.last }
          it { should be_a Gauge::DB::Constraints::UniqueConstraint }
          its(:name) { should == 'uc_dbo_trades_batch_id' }
          its(:table) { should == :dbo_trades }
          its(:columns) { should have(1).column }
          its(:columns) { should include(:batch_id) }
          it { should_not be_composite }
        end

        context "when the composite unique constraint is defined on the table" do
          before do
            @reps_table = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code, len: 10
              col :rep_name
              col :office_code, len: 10
              unique [:rep_code, :office_code]
            end
          end
          subject { @reps_table.unique_constraints.first }
          it_behaves_like "composite unique constraint on rep_code and office_code columns"
        end
      end


      describe '#foreign_keys' do
        subject { table_schema.foreign_keys }

        it { should_not be_nil }

        context "when the table does not have foreign keys" do
          it { should be_empty }
        end

        context "when only one foreign key is defined on the table" do
          before do
            @trades_table = DataTableSchema.new(:trades, sql_schema: :bnr) do
              col :ref => 'bnr.products'
            end
          end
          subject { @trades_table.foreign_keys.first }
          it_should_behave_like "product_id foreign key on bnr.trades table"
        end

        context "when multiple foreign keys are defined on the table" do
        end

        context "when composite foreign key is defined on the table" do
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
