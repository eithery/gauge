# Eithery Lab, 2017
# Gauge::Schema::DataTableSchema specs

require 'spec_helper'

module Gauge
  module Schema
    include Errors

    describe DataTableSchema, f: true do

      let(:table) do
        DataTableSchema.new(name: :reps, db: :test_db) do
          col :rep_code
          col :total_amount
        end
      end

      let(:ref_table) do
        DataTableSchema.new(name: :source_firms, sql_schema: :ref, db: :test_db) do
          col :source_firm_id, id: true
        end
      end

      subject { table }

      it { should respond_to :table_id, :table_name, :sql_name }
      it { should respond_to :sql_schema, :local_name }
      it { should respond_to :object_name }
      it { should respond_to :database }
      it { should respond_to :reference_table? }
      it { should respond_to :columns, :contains_column? }
      it { should respond_to :column, :[]}
      it { should respond_to :to_sym }
      it { should respond_to :col, :timestamps }
      it { should respond_to :primary_key }
      it { should respond_to :indexes, :index }
      it { should respond_to :unique_constraints, :unique }
      it { should respond_to :foreign_keys, :foreign_key }
      it { should respond_to :cleanup_sql_files }


      describe '#table_id' do
        context "for a default SQL schema" do
          it "returns a local table name concatenated with 'dbo' and converted to a symbol" do
            expect(table.table_id).to be :dbo_reps
          end

          it "converts a passed full table name with SQL schema to a symbol" do
            table = DataTableSchema.new(name: 'dbo.reps', db: :test_db)
            expect(table.table_id).to be :dbo_reps
          end
        end

        context "for a custom SQL schema" do
          it "concatenates SQL schema and a local table name" do
            expect(ref_table.table_id).to be :ref_source_firms
          end

          it "converts a passed full table name with SQL schema to a symbol" do
            table = DataTableSchema.new(name: 'bnr.reps', db: :test_db)
            expect(table.table_id).to be :bnr_reps
          end
        end
      end


      describe '#to_sym' do
        it "always returns a table_id" do
          expect(table.to_sym).to be table.table_id
          expect(ref_table.to_sym).to be ref_table.table_id
        end
      end


      describe '#table_name' do
        context "when a data table defined in a default SQL schema" do
          it { expect(table.table_name).to eq 'dbo.reps' }
        end

        context "when a data table is defined in a custom SQL schema" do
          it { expect(ref_table.table_name).to eq 'ref.source_firms' }
        end
      end


      describe '#sql_name' do
        it { expect(table.sql_name).to eq table.table_name }
      end


      describe '#local_name' do
        context "when a data table is defined in a default SQL schema" do
          it { expect(table.local_name).to eq 'reps' }
        end

        context "when a data table is defined in a custom SQL schema" do
          it { expect(ref_table.local_name).to eq 'source_firms' }
        end
      end


      describe '#sql_schema' do
        context "when a data table is defined in a default SQL schema" do
          it { expect(table.sql_schema).to be :dbo }
        end

        context "when a data table is defined in a custom SQL schema" do
          it { expect(ref_table.sql_schema).to be :ref }
        end
      end


      describe '#object_name' do
        it { expect(table.object_name).to eq 'Data table' }
      end


      describe '#database' do
        it { expect(table.database).to be :test_db }

        it "could be passed as a string" do
          table = DataTableSchema.new(name: :accounts, db: 'Package_Me')
          expect(table.database).to be :package_me
        end

        it "is converted to a lowercase symbol" do
          table = DataTableSchema.new(name: :accounts, db: 'REPPROFILE')
          expect(table.database).to be :repprofile
        end
      end


      describe '#reference_table?' do
        it "returns true for reference table types" do
          table = DataTableSchema.new(name: :activation_reasons, db: :test_db, table_type: :reference)
          expect(table.reference_table?).to be true
        end

        it "returns true if ref SQL schema defined for a table" do
          table = DataTableSchema.new(name: :risk_tolerance, sql_schema: :ref, db: :test_db)
          expect(table.reference_table?).to be true
        end

        it "returns false when a data table is not a reference table" do
          table = DataTableSchema.new(name: :master_accounts, db: :test_db)
          expect(table.reference_table?).to be false
        end
      end


      describe '#columns' do
        context "when id column is taken by convention" do
          it "contains the number of columns defined in metadata + 1" do
            expect(table).to have(3).columns
            expect(table).to contain_columns(:rep_code, :total_amount)
            expect(table).to_not contain_columns(:account_number)
          end

          it "contains 'id' data column" do
            expect(table).to contain_columns(:id)
          end
        end

        context "when id column is defined in metadata" do
          let(:table_with_id) do
            DataTableSchema.new(name: :carriers, db: :test_db) do
              col :carrier_id, id: true
              col :code
            end
          end

          it "contains exact number of columns defined in metadata" do
            expect(table_with_id).to have(2).columns
            expect(table_with_id).to contain_columns(:code)
            expect(table_with_id).to_not contain_columns(:display_name)
          end

          it "contains a data column defined as id" do
            expect(table_with_id).to contain_columns(:carrier_id)
            expect(table_with_id).to_not contain_columns(:id)
          end
        end

        context "when a table defines timestamps" do
          it "contains default timestamp columns and id" do
            table_with_timestamps = DataTableSchema.new(name: :customers, db: :test_db) { timestamps }
            expect(table_with_timestamps).to have(6).columns
            expect(table_with_timestamps).to contain_columns(:id, :created_at, :created_by, :updated_at,
              :updated_by, :version)
            expect(table_with_timestamps).to_not contain_columns(:createdBy, :modifiedBy)
          end
        end

        context "when no columns specified in metadata" do
          let(:empty_table) { DataTableSchema.new(name: :customers, db: :test_db) }

          it "contains only one 'id' data column" do
            expect(empty_table.columns).to have(1).column
            expect(empty_table).to contain_columns(:id)
          end
        end
      end


      describe '#contains_column?' do
        context "when a column defined in a table definition" do
          it { expect(table.contains_column?(:rep_code)).to be true }
          it { expect(table.contains_column?('rep_code')).to be true }
        end

        context "when a column is not defined" do
          it { expect(table.contains_column?(:account_number)).to be false }
          it { expect(table.contains_column?(':account_number')).to be false }
        end
      end


      describe '#column' do
        it "returns a column when it exists in the table" do
          expect(table.column(:rep_code)).to be_a DataColumnSchema
          expect(table.column(:rep_code).column_id).to be :rep_code 
          expect(table.column('REP_CODE').column_id).to be :rep_code 
        end

        it "return nil when a column does not exist in the table" do
          expect(table.column(:office_code)).to be nil
        end
      end


      describe '#[]' do
        it "is a #column method alias" do
          expect(table[:rep_code]).to be table.column(:rep_code)
          expect(table[:office_code]).to be table.column(:office_code)
        end
      end


      describe '#col' do
        let(:column) { table.columns.last }

        it "creates a new data column schema" do
          column = double('column', table: table)
          DataColumnSchema.should_receive(:new).with(name: :office_code, table: table, type: :string).and_return(column)
          table.col :office_code, type: :string
        end

        it "adds a new column schema to columns collection" do
          expect { table.col :office_code }.to change { table.columns.count }.by(1)
        end

        it "sets a data table attribute for newly created data column" do
          table.col :office_code, type: :string
          expect(column.table).to be table

          table.col :ref => 'ref.risk_tolerance'
          expect(column.table).to be table

          table.col :ref => :investment_time_horizon, schema: :ref
          expect(column.table).to be table
        end

        it "sets a column name if it is defined explicitly" do
          table.col :office_code, len: 10
          expect(column.column_name).to eq 'office_code'
          expect(column.column_id).to be :office_code
          expect(column.length).to eq 10
        end

        context "when a column name is not defined" do
          it "tries to infer a column name from ref options" do
            table.col :ref => 'ref.risk_tolerance'
            expect(column.column_name).to eq 'risk_tolerance_id'
            expect(column.column_id).to be :risk_tolerance_id
          end

          it "passes other options to DataColumnSchema instance" do
            table.col :ref => 'ref.offices', required: true, len: 10
            expect(column.has_foreign_key?).to be true
            expect(column.allow_null?).to be false
            expect(column.length).to eq 10
          end
        end
      end


      describe '#timestamps' do
        let(:table) { DataTableSchema.new(name: :reps, db: :test_db) }

        it "creates 5 new data column schema instances" do
          column = DataColumnSchema.new(name: :office_code, table: 'master_accounts')
          expect(DataColumnSchema).to receive(:new).at_least(5).times.and_return(column)
          table.timestamps
        end

        it "adds 5 new column schema instances to columns collection" do
          expect { table.timestamps }.to change { table.columns.count }.by(5)
        end

        it "adds version column" do
          table.timestamps
          expect(table).to contain_columns(:version)
          version_column = table.columns.last
          expect(version_column.column_name).to eq 'version'
          expect(version_column.column_type).to be :int
          expect(version_column.allow_null?).to be true
          expect(version_column.default_value).to be nil
        end

        it "adds datetime columns tracking create and update operations" do
          table.timestamps
          expect(table[:created_at].column_type).to be :datetime
          expect(table[:updated_at].column_type).to be :datetime
          expect(table[:created_at].allow_null?).to be false
          expect(table[:updated_at].allow_null?).to be false
        end

        it "adds string columns tracking who perform create and update operations" do
          table.timestamps
          expect(table[:created_by].column_type).to be :string
          expect(table[:updated_by].column_type).to be :string
          expect(table[:created_by].allow_null?).to be false
          expect(table[:updated_by].allow_null?).to be false
          expect(table[:created_by].length).to eq 255
          expect(table[:updated_by].length).to eq 255
        end

        context "when no timestamp columns specified" do
          it "contains default timestamp columns" do
            table.timestamps
            expect(table).to have(6).columns
            expect(table).to contain_columns(:created_at, :updated_at, :created_by, :updated_by, :version)
            expect(table).to_not contain_columns(:modified_at, :modified, :modified_by, :modifiedBy)
          end
        end

        context "when a custom timestamp column naming applied" do
          it "allows to override timestamp column names" do
            table.timestamps :created, :createdBy, :modified, :modifiedBy
            expect(table).to contain_columns(:created, :createdBy, :modified, :modifiedBy, :version)
            expect(table).to_not contain_columns(:created_at, :created_by, :updated_at, :updated_by)
          end

          it "allows to override one or more timestamp columns" do
            table.timestamps :modified_by, :modified
            expect(table).to contain_columns(:created_at, :created_by, :modified, :modified_by, :version)
            expect(table).to_not contain_columns(:updated_at, :updated_by)
          end

          it "ignores non-timestamp columns" do
            table.timestamps :column1, :rep_code
            expect(table).to contain_columns(:created_at, :updated_at, :created_by, :updated_by, :version)
            expect(table).to_not contain_columns(:column1, :rep_code)
          end
        end
      end


      describe '#primary_key' do
        subject { table.primary_key }

        it { expect(table.primary_key).to_not be nil }
        it { expect(table.primary_key).to be_a DB::Constraints::PrimaryKeyConstraint }

        it "returns the same object instance" do
          key = table.primary_key
          expect(table.primary_key).to be_equal(key)
          expect(key).to be_equal(table.primary_key)
        end

        context "when a primary key defined by convention" do
          it { expect(table.primary_key.columns).to have(1).column }
          it_behaves_like "a primary key", name: 'pk_dbo_reps', table: :dbo_reps, column: :id
          it { expect(table.primary_key).to be_clustered }
        end

        context "when a primary key defined using :id attribute" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code, id: true
              col :rep_name
            end
          end

          it { expect(table.primary_key.columns).to have(1).column }
          it_behaves_like "a primary key", name: 'pk_bnr_reps', table: :bnr_reps, column: :rep_code
          it { expect(table.primary_key).to be_clustered }
        end

        context "when a primary key is not clustered" do
          let(:table) do
            DataTableSchema.new(name: :source_firms, sql_schema: :ref, db: :test_db) do
              col :code, len: 10, business_id: true
              col :source_name
            end
          end

          it { expect(table.primary_key.columns).to have(1).column }
          it_behaves_like "a primary key", name: 'pk_ref_source_firms', table: :ref_source_firms, column: :id
          it { expect(table.primary_key).to_not be_clustered }
        end

        context "when a primary key is composite" do
          let(:table) do
            DataTableSchema.new(name: :account_owners, db: :test_db) do
              col :master_account_id, :ref => :br_master_account, id: true
              col :natural_owner_id, :ref => :br_natural_owner, id: true
              col :ordinal, type: :byte, required: true, check: '> 0'
            end
          end

          it { expect(table.primary_key.table).to be table.to_sym }
          it { expect(table.primary_key.columns).to have(2).columns }
          it_behaves_like "a primary key", name: 'pk_dbo_account_owners',
            table: :dbo_account_owners, columns: [:master_account_id, :natural_owner_id]
          it { expect(table.primary_key).to be_clustered }
        end

        context "when a business key defined" do
          let(:table) do
            DataTableSchema.new(name: :reps, db: :test_db) do
              col :rep_id, id: true
              col :rep_code, business_id: true
            end
          end

          it { expect(table.primary_key.columns).to include :rep_id }
          it { expect(table.primary_key).to_not be_clustered }
        end

        context "when a clustered index defined" do
          let(:table) do
            DataTableSchema.new(name: :reps, db: :test_db) do
              col :rep_id, id: true
              col :rep_code, index: { clustered: true }
            end
          end

          it { expect(table.primary_key.columns).to include :rep_id }
          it { expect(table.primary_key).to_not be_clustered }
        end

        context "when a composite clustered index defined" do
          let(:table) do
            DataTableSchema.new(name: :fund_accounts, db: :test_db) do
              col :fund_account_number
              col :cusip, len: 9
              index [:fund_account_number, :cusip], clustered: true
            end
          end

          it { expect(table.primary_key.columns).to include :id }
          it { expect(table.primary_key).to_not be_clustered }
        end
      end


      describe '#indexes' do
        subject(:index) { table.indexes.first }

        it { expect(table.indexes).to_not be nil }

        context "when no indexes defined" do
          it { expect(table.indexes).to be_empty }
        end

        context "when one index is defined" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code, index: true
            end
          end

          it { expect(table.indexes).to have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
          it { expect(index).to_not be_clustered }
          it { expect(index).to_not be_unique }
        end

        context "when multiple indexes defined" do
          let(:table) do
            DataTableSchema.new(name: :trades, db: :test_db) do
              col :batch_id, index: true
              col :trade_id, index: true
              col :rep_code, index: true
            end
          end

          it { expect(table.indexes).to have(3).items }
          it_behaves_like "an index", name: 'idx_dbo_trades_batch_id', table: :dbo_trades, column: :batch_id
          it { expect(index).to_not be_clustered }
          it { expect(index).to_not be_unique }
        end

        context "when an unique index is defined" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_id, id: true
              col :rep_code, index: { unique: true }
            end
          end

          it { expect(table.indexes).to have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
          it { expect(index).to_not be_clustered }
          it { expect(index).to be_unique }
        end

        context "when a clustered index is defined" do
          context "as a regular one column index" do
            let(:table) do
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code, index: { clustered: true }
                col :rep_name
              end
            end

            it { expect(table.indexes).to have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
            it { expect(index).to be_clustered }
            it { expect(index).to be_unique }
          end

          context "as a natural business key (using 'business_id')" do
            let(:table) do
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code, business_id: true
                col :rep_name
              end
            end

            it { expect(table.indexes).to have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
            it { expect(index).to be_clustered }
            it { expect(index).to be_unique }
          end

          context "as an implicit index defined on a foreign key column" do
            let(:table) do
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code
                col :ref => 'bnr.offices', required: true
              end
            end

            it { expect(table.indexes).to have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_office_id', table: :bnr_reps, column: :office_id
            it { expect(index).to_not be_clustered }
            it { expect(index).to_not be_unique }
          end
        end

        context "when a composite (multicolumn) index defined" do
          context "and it is a regular (nonclustered and not unique)" do
            let(:table) do
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code]
              end
            end

            it { expect(table.indexes).to have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
              table: :bnr_reps, columns: [:rep_code, :office_code]
            it { expect(index).to_not be_clustered }
            it { expect(index).to_not be_unique }
          end

          context "and it is unique" do
            let(:table) do
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code], unique: true
              end
            end

            it { expect(table.indexes).to have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
              table: :bnr_reps, columns: [:rep_code, :office_code]
            it { expect(index).to_not be_clustered }
            it { expect(index).to be_unique }
          end

          context "and it is clustered" do
            let(:table) do
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code], clustered: true
              end
            end

            it { expect(table.indexes).to have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
              table: :bnr_reps, columns: [:rep_code, :office_code]
            it { expect(index).to be_clustered }
            it { expect(index).to be_unique }
          end

          context "and it is clustered but not unique" do
            let(:table) do
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code, len: 10
                col :rep_name
                col :office_code, len: 10
                index [:rep_code, :office_code], clustered: true, unique: false
              end
            end
            it { expect(table.indexes).to have(1).item }
            it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
              table: :bnr_reps, columns: [:rep_code, :office_code]
            it { expect(index).to be_clustered }
            it { expect(index).to be_unique }
          end

          context "and it is a natural business key (using 'business_id')" do
            let(:table) do
              DataTableSchema.new(name: :fund_accounts, db: :test_db) do
                col :fund_account_number, len: 20, business_id: true
                col :cusip, len: 9, business_id: true
              end
            end

            it { expect(table.indexes).to have(1).item }
            it_behaves_like "an index", name: 'idx_dbo_fund_accounts_fund_account_number_cusip',
              table: :dbo_fund_accounts, columns: [:fund_account_number, :cusip]
            it { expect(index).to be_clustered }
            it { expect(index).to be_unique }
          end
        end
      end


      describe '#index' do
        subject(:index) { table.indexes.first }

        it "creates a new index" do
          expect(Gauge::DB::Index).to receive(:new).with('idx_dbo_reps_rep_code',
            hash_including(table: 'dbo.reps', columns: :rep_code, clustered: true))
          table.col :rep_code
          table.index :rep_code, clustered: true
        end

        it "adds a new index to indexes collection" do
          index = double('index')
          Gauge::DB::Index.stub(:new).and_return(index)
          table.col :rep_code
          expect { table.index :rep_code }.to change { table.indexes.count }.by(1)
          expect(table.indexes).to include(index)
        end

        context "for a regular one column index" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code
              col :rep_name
              index :rep_code
            end
          end

          it { expect(table.indexes).to have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
          it { expect(index).to_not be_clustered }
          it { expect(index).to_not be_unique }
        end

        context "for a composite index" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code
              col :office_code
              index [:rep_code, :office_code]
            end
          end

          it { expect(table.indexes).to have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
            table: :bnr_reps, columns: [:rep_code, :office_code]
          it { expect(index).to_not be_clustered }
          it { expect(index).to_not be_unique }
        end

        context "when an index defined as unique" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code
              col :office_code
              index [:rep_code, :office_code], unique: true
            end
          end

          it { expect(table.indexes).to have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
            table: :bnr_reps, columns: [:rep_code, :office_code]
          it { expect(index).to_not be_clustered }
          it { expect(index).to be_unique }
        end

        context "when an index is defined as clustered" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code
              col :office_code
              index [:rep_code, :office_code], clustered: true
            end
          end

          it { expect(table.indexes).to have(1).item }
          it_behaves_like "an index", name: 'idx_bnr_reps_rep_code_office_code',
            table: :bnr_reps, columns: [:rep_code, :office_code]
          it { expect(index).to be_clustered }
          it { expect(index).to be_unique }
        end

        context "when an index defined on a missing column" do
          it "raises an error" do
            expect {
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code
                col :rep_name
                index [:rep_code, :office_code]
              end
            }.to raise_error(InvalidMetadataError, /missing column 'office_code' in bnr.reps data table/i)
          end
        end
      end


      describe '#unique_constraints' do
        subject { table.unique_constraints.first }

        it { expect(table.unique_constraints).to_not be nil }

        context "when no unique constraints defined" do
          it { expect(table.unique_constraints).to be_empty }
        end

        context "when one unique constraint defined" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code, unique: true
            end
          end

          it { expect(table.unique_constraints).to have(1).item }
          it_behaves_like "a unique constraint", name: 'uc_bnr_reps_rep_code',
            table: :bnr_reps, column: :rep_code
        end

        context "when multiple unique constraints defined" do
          let(:table) do
            DataTableSchema.new(name: :trades, db: :test_db) do
              col :batch_id, unique: true
              col :trade_id, unique: true
              col :rep_code, unique: true
            end
          end

          it { expect(table.unique_constraints).to have(3).items }
          it_behaves_like "a unique constraint", name: 'uc_dbo_trades_batch_id', table: :dbo_trades, column: :batch_id
        end

        context "when a composite unique constraint defined" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code, len: 10
              col :rep_name
              col :office_code, len: 10
              unique [:rep_code, :office_code]
            end
          end

          it { expect(table.unique_constraints).to have(1).item }
          it_behaves_like "a unique constraint", name: 'uc_bnr_reps_rep_code_office_code',
            table: :bnr_reps, columns: [:rep_code, :office_code]
        end
      end


      describe '#unique' do
        subject { table.unique_constraints.first }

        it "creates a new unique constraint" do
          expect(Gauge::DB::Constraints::UniqueConstraint).to receive(:new).with('uc_dbo_reps_rep_code',
            hash_including(table: 'dbo.reps', columns: :rep_code))
          table.col :rep_code
          table.unique :rep_code
        end

        it "adds a new unique constraint to the unique constraints collection" do
          unique_constraint = double('unique_constraint')
          Gauge::DB::Constraints::UniqueConstraint.stub(:new).and_return(unique_constraint)
          table.col :rep_code
          expect { table.unique :rep_code }.to change { table.unique_constraints.count }.by(1)
          expect(table.unique_constraints).to include(unique_constraint)
        end

        context "for a regular unique constraint defined on one column" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code
              col :rep_name
              unique :rep_code
            end
          end

          it { expect(table.unique_constraints).to have(1).item }
          it_behaves_like "a unique constraint", name: 'uc_bnr_reps_rep_code', table: :bnr_reps, column: :rep_code
        end

        context "for a composite unique constraint" do
          let(:table) do
            DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code
              col :office_code
              unique [:rep_code, :office_code]
            end
          end

          it { expect(table.unique_constraints).to have(1).item }
          it_behaves_like "a unique constraint", name: 'uc_bnr_reps_rep_code_office_code',
            table: :bnr_reps, columns: [:rep_code, :office_code]
        end

        context "when a unique constraint defined on missing column" do
          it "raises an error" do
            expect {
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code
                col :rep_name
                unique [:rep_code, :office_code]
              end
            }.to raise_error(InvalidMetadataError, /missing column 'office_code' in bnr.reps data table/i)
          end
        end
      end


      describe '#foreign_keys' do
        subject { table.foreign_keys.first }

        it { expect(table.foreign_keys).to_not be_nil }

        context "when no foreign keys defined" do
          it { expect(table.foreign_keys).to be_empty }
        end

        context "when one foreign key defined" do
          let(:table) do
            DataTableSchema.new(name: :trades, sql_schema: :bnr, db: :test_db) do
              col :ref => 'bnr.products'
            end
          end

          it { expect(table.foreign_keys).to have(1).item }
          it_behaves_like "a foreign key constraint", name: 'fk_bnr_trades_bnr_products_product_id',
            table: :bnr_trades, column: :product_id, ref_table: :bnr_products, ref_column: :id
        end

        context "when multiple foreign keys defined" do
          let(:table) do
            DataTableSchema.new(name: :trades, sql_schema: :bnr, db: :test_db) do
              col :rep_code, :ref => { table: :reps, column: :code }
              col :ref => 'bnr.products'
            end
          end

          it { expect(table.foreign_keys).to have(2).items }
          it_behaves_like "a foreign key constraint", name: 'fk_bnr_trades_dbo_reps_rep_code',
            table: :bnr_trades, column: :rep_code, ref_table: :dbo_reps, ref_column: :code
        end

        context "when a composite foreign key is defined" do
          let(:table) do
            DataTableSchema.new(name: :trades, sql_schema: :bnr, db: :test_db) do
              col :fund_account_number, len: 20, required: true
              col :product_cusip, len: 9, required: true
              foreign_key [:fund_account_number, :product_cusip], ref_table: :fund_accounts,
                ref_columns: [:fund_account_number, :cusip]
            end
          end

          it { expect(table.foreign_keys).to have(1).item }
          it_behaves_like "a foreign key constraint",
            name: 'fk_bnr_trades_dbo_fund_accounts_fund_account_number_product_cusip',
            table: :bnr_trades, columns: [:fund_account_number, :product_cusip], ref_table: :dbo_fund_accounts,
            ref_columns: [:fund_account_number, :cusip]
        end
      end


      describe '#foreign_key' do
        subject { table.foreign_keys.last }

        it "creates a new foreign key" do
          expect(Gauge::DB::Constraints::ForeignKeyConstraint).to receive(:new).with('fk_dbo_reps_dbo_offices_office_code',
            hash_including(table: 'dbo.reps', columns: :office_code, ref_table: :offices, ref_columns: :code))
          table.col :office_code
          table.foreign_key :office_code, ref_table: :offices, ref_columns: :code
        end

        it "adds a new foreign key to foreign_keys collection" do
          foreign_key = double('foreign_key')
          Gauge::DB::Constraints::ForeignKeyConstraint.stub(:new).and_return(foreign_key)
          table.col :office_code
          expect { table.foreign_key :office_code, ref_table: :offices, ref_columns: :code }
            .to change { table.foreign_keys.count }.by(1)
          expect(table.foreign_keys).to include(foreign_key)
        end

        context "for a regular one column" do
          context "referenced to a table in default SQL schema" do
            let(:table) do
              DataTableSchema.new(name: :reps, db: :test_db) do
                col :office_code
                foreign_key :office_code, ref_table: :offices, ref_columns: :code
              end
            end

            it { expect(table.foreign_keys).to have(1).item }
            it_behaves_like "a foreign key constraint", name: 'fk_dbo_reps_dbo_offices_office_code',
              table: :dbo_reps, column: :office_code, ref_table: :dbo_offices, ref_column: :code
          end

          context "referenced to a table in custom SQL schema" do
            let(:table) do
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :office_code
                foreign_key :office_code, ref_table: 'bnr.offices', ref_columns: :code
              end
            end

            it { expect(table.foreign_keys).to have(1).item }
            it_behaves_like "a foreign key constraint", name: 'fk_bnr_reps_bnr_offices_office_code',
              table: :bnr_reps, column: :office_code, ref_table: :bnr_offices, ref_column: :code
          end
        end

        context "for a composite foreign key" do
          context "referenced to a table in default SQL schema" do
            let(:table) do
              DataTableSchema.new(name: :trades, db: :test_db) do
                col :fund_account_number
                col :product_cusip
                foreign_key [:fund_account_number, :product_cusip], ref_table: :fund_accounts,
                  ref_columns: [:number, :cusip]
              end
            end

            it { expect(table.foreign_keys).to have(1).item }
            it_behaves_like "a foreign key constraint",
              name: 'fk_dbo_trades_dbo_fund_accounts_fund_account_number_product_cusip',
              table: :dbo_trades, columns: [:fund_account_number, :product_cusip],
              ref_table: :dbo_fund_accounts, ref_columns: [:number, :cusip]
          end

          context "referenced to a table in custom SQL schema" do
            let(:table) do
              DataTableSchema.new(name: 'bnr.trades', db: :test_db) do
                col :fund_account_number
                col :product_cusip
                foreign_key [:fund_account_number, :product_cusip], ref_table: 'bnr.fund_accounts',
                  ref_columns: [:number, :cusip]
              end
            end

            it { expect(table.foreign_keys).to have(1).item }
            it_behaves_like "a foreign key constraint",
              name: 'fk_bnr_trades_bnr_fund_accounts_fund_account_number_product_cusip',
              table: :bnr_trades, columns: [:fund_account_number, :product_cusip],
              ref_table: :bnr_fund_accounts, ref_columns: [:number, :cusip]
          end
        end

        context "when a foreign key defined on missing data column" do
          it "raises an error" do
            expect {
              DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code
                foreign_key :office_code, ref_table: :offices, ref_columns: :code
              end
            }.to raise_error(InvalidMetadataError, /missing column 'office_code' in bnr.reps data table/i)
          end
        end
      end


      describe '#cleanup_sql_files' do
        it "deletes all SQL migration files belong to a data table" do
          expect(FileUtils).to receive(:remove_file).with(/\/sql\/test_db\/tables\/create_dbo_reps.sql/,
            hash_including(force: true)).once
          expect(FileUtils).to receive(:remove_file).with(/\/sql\/test_db\/tables\/alter_dbo_reps.sql/,
            hash_including(force: true)).once
          expect(FileUtils).to receive(:remove_file).with(/\/sql\/test_db\/tables\/drop_dbo_reps.sql/,
            hash_including(force: true)).once
          table.cleanup_sql_files
        end
      end


  private

      def expect_added_columns(*columns)
        expect(table).to_not contain_columns(columns)
        yield
        expect(table).to contain_columns(columns)
      end
    end
  end
end
