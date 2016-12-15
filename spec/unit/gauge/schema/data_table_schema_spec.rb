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
        subject { @reps.indexes.first }

        it "creates new index" do
          Gauge::DB::Index.should_receive(:new).with('idx_dbo_master_accounts_rep_code', 'dbo.master_accounts',
            :rep_code, hash_including(clustered: true))
          table_schema.col :rep_code
          table_schema.index :rep_code, clustered: true
        end

        it "adds new index to indexes collection" do
          index_stub = double('index')
          Gauge::DB::Index.stub(:new).and_return(index_stub)
          table_schema.col :rep_code
          expect { table_schema.index :rep_code }.to change { table_schema.indexes.count }.by(1)
          table_schema.indexes.should include(index_stub)
        end

        context "when index includes one column" do
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :rep_name
              index :rep_code
            end
          end

          specify { @reps.indexes.should have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
          it { is_expected.not_to be_clustered }
          it { is_expected.not_to be_unique }
        end

        context "when index defined on multiple columns" do
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :office_code
              index [:rep_code, :office_code]
            end
          end

          specify { @reps.indexes.should have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
            table: :bnr_reps, columns: [:rep_code, :office_code]
          it { is_expected.not_to be_clustered }
          it { is_expected.not_to be_unique }
        end

        context "when index defined as unique" do
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :office_code
              index [:rep_code, :office_code], unique: true
            end
          end

          specify { @reps.indexes.should have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
            table: :bnr_reps, columns: [:rep_code, :office_code]
          it { is_expected.not_to be_clustered }
          it { is_expected.to be_unique }
        end

        context "when index is defined as clustered" do
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :office_code
              index [:rep_code, :office_code], clustered: true
            end
          end

          specify { @reps.indexes.should have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
            table: :bnr_reps, columns: [:rep_code, :office_code]
          it { is_expected.to be_clustered }
          it { is_expected.to be_unique }
        end

        context "when index defined on missing column" do
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
        subject { @reps.unique_constraints.first }

        it "creates new unique constraint" do
          Gauge::DB::Constraints::UniqueConstraint.should_receive(:new).with('uc_dbo_master_accounts_rep_code',
            'dbo.master_accounts', :rep_code)
          table_schema.col :rep_code
          table_schema.unique :rep_code
        end

        it "adds new unique constraint" do
          constraint_stub = double('unique_constraint')
          Gauge::DB::Constraints::UniqueConstraint.stub(:new).and_return(constraint_stub)
          table_schema.col :rep_code
          expect { table_schema.unique :rep_code }.to change { table_schema.unique_constraints.count }.by(1)
          table_schema.unique_constraints.should include(constraint_stub)
        end

        context "when unique constraint defined one column" do
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :rep_name
              unique :rep_code
            end
          end

          specify { @reps.unique_constraints.should have(1).item }
          it_behaves_like "a unique constraint", name: 'uc_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
        end

        context "when unique constraint defined on multiple columns" do
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code
              col :office_code
              unique [:rep_code, :office_code]
            end
          end

          specify { @reps.unique_constraints.should have(1).item }
          it_behaves_like "a unique constraint", name: 'uc_bnr_reps_rep_code_office_code',
            table: :bnr_reps, columns: [:rep_code, :office_code]
        end

        context "when unique constraint defined on missing column" do
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

        it { is_expected.not_to be_nil }
        it { is_expected.to be_a DB::Constraints::PrimaryKeyConstraint }

        it "returns the same object instance" do
          key = table_schema.primary_key
          table_schema.primary_key.should be_equal(key)
          key.should be_equal(subject)
        end

        context "when primary key defined by convention" do
          specify { table_schema.primary_key.columns.should have(1).column }
          it_behaves_like "a primary key", name: 'pk_dbo_master_accounts', table: :dbo_master_accounts, column: :id
          it { is_expected.to be_clustered }
        end

        context "when primary key defined using :id attribute" do
          subject { @reps.primary_key }
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code, id: true
              col :rep_name
            end
          end

          specify { @reps.primary_key.columns.should have(1).column }
          it_behaves_like "a primary key", name: 'pk_bnr_reps', table: :bnr_reps, column: :rep_code
          it { is_expected.to be_clustered }
        end

        context "when nonclustered primary key " do
          subject { @source_firms.primary_key }
          before do
            @source_firms = DataTableSchema.new(:source_firms, sql_schema: :ref) do
              col :code, len: 10, business_id: true
              col :source_name
            end
          end

          specify { @source_firms.primary_key.columns.should have(1).column }
          it_behaves_like "a primary key", name: 'pk_ref_source_firms', table: :ref_source_firms, column: :id
          it { is_expected.not_to be_clustered }
        end

        context "when primary key is composite" do
          subject(:primary_key) { @account_owners.primary_key }
          before do
            @account_owners = DataTableSchema.new(:account_owners) do
              col :master_account_id, :ref => :br_master_account, id: true
              col :natural_owner_id, :ref => :br_natural_owner, id: true
              col :ordinal, type: :byte, required: true, check: '> 0'
            end
          end

          it { expect(primary_key.table).to eq @account_owners.to_sym }
          specify { @account_owners.primary_key.columns.should have(2).columns }
          it_behaves_like "a primary key", name: 'pk_dbo_account_owners',
            table: :dbo_account_owners, columns: [:master_account_id, :natural_owner_id]
          it { is_expected.to be_clustered }
        end

        context "when business key defined" do
          subject { @reps.primary_key }
          before do
            @reps = DataTableSchema.new(:reps) do
              col :rep_id, id: true
              col :rep_code, business_id: true
            end
          end

          it { is_expected.not_to be_clustered }
        end

        context "when clustered index defined" do
          subject { @reps.primary_key }
          before do
            @reps = DataTableSchema.new(:reps) do
              col :rep_id, id: true
              col :rep_code, index: { clustered: true }
            end
          end

          it { is_expected.not_to be_clustered }
        end

        context "when composite clustered index defined" do
          subject(:primary_key) { @fund_accounts.primary_key }
          before do
            @fund_accounts = DataTableSchema.new(:fund_accounts) do
              col :fund_account_number
              col :cusip, len: 9
              index [:fund_account_number, :cusip], clustered: true
            end
          end

          it { expect(primary_key.columns).to include :id }
          it { is_expected.not_to be_clustered }
        end
      end


      describe '#indexes' do
        subject { table_schema.indexes }

        it { is_expected.not_to be_nil }

        context "when no indexes defined" do
          it { is_expected.to be_empty }
        end

        context "when one index is defined" do
          subject { @reps.indexes.first }
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code, index: true
            end
          end

          specify { @reps.indexes.should have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
          it { is_expected.not_to be_clustered }
          it { is_expected.not_to be_unique }
        end

        context "when multiple indexes defined" do
          subject { @trades.indexes.last }
          before do
            @trades = DataTableSchema.new(:trades) do
              col :trade_id, index: true
              col :rep_code, index: true
              col :batch_id, index: true
            end
          end

          specify { @trades.indexes.should have(3).items }
          it_behaves_like "an index", name: 'idx_dbo_trades_batch_id',
            table: :dbo_trades, column: :batch_id
          it { is_expected.not_to be_clustered }
          it { is_expected.not_to be_unique }
        end

        context "when unique index is defined" do
          subject { @reps.indexes.first }
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_id, id: true
              col :rep_code, index: { unique: true }
            end
          end

          specify { @reps.indexes.should have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
          it { is_expected.not_to be_clustered }
          it { is_expected.to be_unique }
        end

        context "when clustered index is defined" do
          subject { @reps.indexes.first }
          context "as regular index" do
            before do
              @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, index: { clustered: true }
                col :rep_name
              end
            end

            specify { @reps.indexes.should have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
            it { is_expected.to be_clustered }
            it { is_expected.to be_unique }
          end

          context "as natural business key (using 'business_id')" do
            subject { @reps.indexes.first }
            before do
              @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, business_id: true
                col :rep_name
              end
            end

            specify { @reps.indexes.should have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
            it { is_expected.to be_clustered }
            it { is_expected.to be_unique }
          end

          context "as implicit index defined on foreign key column" do
            subject { @reps.indexes.first }
            before do
              @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code
                col :ref => 'bnr.offices', required: true
              end
            end

            specify { @reps.indexes.should have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_office_id', table: :bnr_reps, column: :office_id
            it { is_expected.not_to be_clustered }
            it { is_expected.not_to be_unique }
          end
        end

        context "when composite (multicolumn) index defined" do
          subject { @reps.indexes.first }

          context "and it is regular (nonclustered and not unique)" do
            before do
              @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code]
              end
            end

            specify { @reps.indexes.should have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
              table: :bnr_reps, columns: [:rep_code, :office_code]
            it { is_expected.not_to be_clustered }
            it { is_expected.not_to be_unique }
          end

          context "and it is unique" do
            before do
              @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code], unique: true
              end
            end

            specify { @reps.indexes.should have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
              table: :bnr_reps, columns: [:rep_code, :office_code]
            it { is_expected.not_to be_clustered }
            it { is_expected.to be_unique }
          end

          context "and it is clustered" do
            before do
              @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code], clustered: true
              end
            end

            specify { @reps.indexes.should have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
              table: :bnr_reps, columns: [:rep_code, :office_code]
            it { is_expected.to be_clustered }
            it { is_expected.to be_unique }
          end

          context "and it is clustered but not unique" do
            before do
              @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code], clustered: true, unique: false
              end
            end
            specify { @reps.indexes.should have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
              table: :bnr_reps, columns: [:rep_code, :office_code]
            it { is_expected.to be_clustered }
            it { is_expected.to be_unique }
          end

          context "and it is natural business key (using 'business_id')" do
            subject { @fund_accounts.indexes.first }
            before do
              @fund_accounts = DataTableSchema.new(:fund_accounts) do
                col :fund_account_number, len: 20, business_id: true
                col :cusip, len: 9, business_id: true
              end
            end

            specify { @fund_accounts.indexes.should have(1).item }
            it_behaves_like "an index", name: 'idx_dbo_fund_accounts_fund_account_number_cusip',
              table: :dbo_fund_accounts, columns: [:fund_account_number, :cusip]
            it { is_expected.to be_clustered }
            it { is_expected.to be_unique }
          end
        end
      end


      describe '#unique_constraints' do
        subject { table_schema.unique_constraints }

        it { is_expected.not_to be_nil }

        context "when no unique constraints defined" do
          it { is_expected.to be_empty }
        end

        context "when one unique constraint defined" do
          subject { @reps.unique_constraints.first }
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code, unique: true
            end
          end

          specify { @reps.unique_constraints.should have(1).item }
          it_behaves_like "a unique constraint", name: 'uc_bnr_reps_rep_code',
            table: :bnr_reps, column: :rep_code
        end

        context "when multiple unique constraints defined" do
          subject { @trades.unique_constraints.last }
          before do
            @trades = DataTableSchema.new(:trades) do
              col :trade_id, unique: true
              col :rep_code, unique: true
              col :batch_id, unique: true
            end
          end

          specify { @trades.unique_constraints.should have(3).items }
          it_behaves_like "a unique constraint", name: 'uc_dbo_trades_batch_id', table: :dbo_trades, column: :batch_id
        end

        context "when composite unique constraint defined" do
          subject { @reps.unique_constraints.first }
          before do
            @reps = DataTableSchema.new(:reps, sql_schema: :bnr) do
              col :rep_code, len: 10
              col :rep_name
              col :office_code, len: 10
              unique [:rep_code, :office_code]
            end
          end

          specify { @reps.unique_constraints.should have(1).item }
          it_behaves_like "a unique constraint", name: 'uc_bnr_reps_rep_code_office_code',
            table: :bnr_reps, columns: [:rep_code, :office_code]
        end
      end


      describe '#foreign_keys' do
        subject { table_schema.foreign_keys }

        it { is_expected.not_to be_nil }

        context "when no foreign keys defined" do
          it { is_expected.to be_empty }
        end

        context "when one foreign key defined" do
          subject { @trades_table.foreign_keys.first }
          before do
            @trades_table = DataTableSchema.new(:trades, sql_schema: :bnr) do
              col :ref => 'bnr.products'
            end
          end

          specify { @trades_table.foreign_keys.should have(1).item }
          it_behaves_like "a foreign key constraint", name: 'fk_bnr_trades_bnr_products_product_id',
            table: :bnr_trades, column: :product_id, ref_table: :bnr_products, ref_column: :id
        end

        context "when multiple foreign keys defined" do
          subject { @trades_table.foreign_keys.first }
          before do
            @trades_table = DataTableSchema.new(:trades, sql_schema: :bnr) do
              col :rep_code, :ref => { table: :reps, column: :code }
              col :ref => 'bnr.products'
            end
          end

          specify { @trades_table.foreign_keys.should have(2).items }
          it_behaves_like "a foreign key constraint", name: 'fk_bnr_trades_dbo_reps_rep_code',
            table: :bnr_trades, column: :rep_code, ref_table: :dbo_reps, ref_column: :code
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
