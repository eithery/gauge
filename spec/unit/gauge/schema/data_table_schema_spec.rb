# Eithery Lab, 2017
# Gauge::Schema::DataTableSchema specs

require 'spec_helper'

module Gauge
  module Schema
    include Errors

    describe DataTableSchema do
      let(:dbo_table_schema) do
        DataTableSchema.new(:master_accounts, db: :test_db) do
          col :account_number
          col :total_amount
        end
      end
      let(:ref_table_schema) do
        DataTableSchema.new(:source_firms, sql_schema: :ref, db: :test_db) do
          col :source_firm_id, id: true
        end
      end
      let(:table_schema) { dbo_table_schema }

      subject { dbo_table_schema }

      it { should respond_to :table_name, :local_name }
      it { should respond_to :sql_schema, :sql_name }
      it { should respond_to :database, :database_name }
      it { should respond_to :object_name }
      it { should respond_to :reference_table? }
      it { should respond_to :columns }
      it { should respond_to :primary_key }
      it { should respond_to :foreign_keys }
      it { should respond_to :indexes, :unique_constraints }
      it { should respond_to :contains? }
      it { should respond_to :col, :timestamps }
      it { should respond_to :index, :unique }
      it { should respond_to :to_sym }
      it { should respond_to :cleanup_sql_files }


      describe '#table_name' do
        context "when a data table defined in a default SQL schema" do
          it { expect(dbo_table_schema.table_name).to eq 'dbo.master_accounts' }
        end

        context "when a data table is defined in a custom SQL schema" do
          it { expect(ref_table_schema.table_name).to eq 'ref.source_firms' }
        end
      end


      describe '#local_name' do
        context "when a data table is defined in a default SQL schema" do
          it { expect(dbo_table_schema.local_name).to eq 'master_accounts' }
        end

        context "when a data table is defined in a custom SQL schema" do
          it { expect(ref_table_schema.local_name).to eq 'source_firms' }
        end
      end


      describe '#object_name' do
        it { expect(table_schema.object_name).to eq 'Data table' }
      end


      describe '#sql_schema' do
        context "when a data table is defined in a default SQL schema" do
          it { expect(dbo_table_schema.sql_schema).to be :dbo }
        end

        context "when a data table is defined in a custom SQL schema" do
          it { expect(ref_table_schema.sql_schema).to be :ref }
        end
      end


      describe '#sql_name' do
        it { expect(table_schema.sql_name).to eq table_schema.table_name }
      end


      describe '#database' do
        it { expect(table_schema.database).to be :test_db }

        it "could be passed as a string" do
          table = DataTableSchema.new(:accounts, db: 'Package_Me')
          expect(table.database).to be :package_me
        end

        it "is converted to a lowercase symbol" do
          table = DataTableSchema.new(:accounts, db: 'REPPROFILE')
          expect(table.database).to be :repprofile
        end
      end


      describe '#database_name' do
        it { expect(table_schema.database_name).to eq 'test_db' }

        it "returns a lowercase string" do
          table = DataTableSchema.new(:accounts, db: 'REPPROFILE')
          expect(table.database_name).to eq 'repprofile'
        end
      end


      describe '#reference_table?' do
        it "returns true for reference table types" do
          table_schema = DataTableSchema.new(:activation_reasons, db: :test_db, table_type: :reference)
          expect(table_schema.reference_table?).to be true
        end

        it "returns true if ref SQL schema defined for a table" do
          table_schema = DataTableSchema.new(:risk_tolerance, sql_schema: :ref, db: :test_db)
          expect(table_schema.reference_table?).to be true
        end

        it "returns false when a data table is not a reference table" do
          table_schema = DataTableSchema.new(:master_accounts, db: :test_db)
          expect(table_schema.reference_table?).to be false
        end
      end


      describe '#to_sym' do
        context "for a default SQL schema" do
          it "returns a local table name concatenated with 'dbo' and converted to a symbol" do
            expect(dbo_table_schema.to_sym).to be :dbo_master_accounts
          end
        end

        context "for a custom SQL schema" do
          it "concatenates SQL schema and a local table name" do
            expect(ref_table_schema.to_sym).to be :ref_source_firms
          end
        end
      end


      describe '#columns' do
        context "when id column is taken by convention" do
          it "contains the number of columns defined in metadata + 1" do
            expect(table_schema).to have(3).columns
            expect(table_schema).to contain_columns(:account_number, :total_amount)
            expect(table_schema).to_not contain_columns(:rep_code)
          end

          it "contains 'id' data column" do
            expect(table_schema).to contain_columns(:id)
          end
        end

        context "when id column is defined in metadata" do
          let(:table_with_id) do
            DataTableSchema.new(:carriers, db: :test_db) do
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

        context "when a table definition contains timestamps" do
          context "in default case" do
            let(:table_with_timestamps) { DataTableSchema.new(:customers, db: :test_db) { timestamps dates: :short }}

            it "contains timestamp columns and id" do
              expect(table_with_timestamps).to have(6).columns
              expect(table_with_timestamps).to contain_columns(:id, :created, :created_by, :modified, :modified_by, :version)
              expect(table_with_timestamps).to_not contain_columns(:createdBy, :modifiedBy)
            end
          end

          context "in snake case" do
            let(:table_with_timestamps) do
              DataTableSchema.new(:customers, db: :test_db) { timestamps naming: :camel, dates: :short }
            end

            it "contains timestamp columns named in snake case and id" do
              expect(table_with_timestamps).to have(6).columns
              expect(table_with_timestamps).to contain_columns(:created, :createdBy, :modified, :modifiedBy, :version, :id)
              expect(table_with_timestamps).to_not contain_columns(:created_by, :modified_by)
            end
          end
        end

        context "when no columns specified in metadata" do
          let(:empty_table_schema) { DataTableSchema.new(:customers, db: :test_db) }

          it "contains only one 'id' data column" do
            expect(empty_table_schema).to have(1).column
            expect(empty_table_schema).to contain_columns(:id)
          end
        end
      end


      describe '#contains?' do
        context "when a column defined in a table definition" do
          it { expect(table_schema.contains?(:account_number)).to be true }
          it { expect(table_schema.contains?('account_number')).to be true }
        end

        context "when a column is not defined" do
          it { expect(table_schema.contains?(:rep_code)).to be false }
          it { expect(table_schema.contains?('rep_code')).to be false }
        end
      end


      describe '#col' do
        it "creates a new data column schema" do
          column = double('column_schema', in_table: table_schema)
          DataColumnSchema.should_receive(:new).with(:office_code, hash_including(type: :string)).and_return(column)
          table_schema.col :office_code, type: :string
        end

        it "adds a new column schema to columns collection" do
          expect { table_schema.col :office_code }.to change { table_schema.columns.count }.by(1)
        end

        it "sets a data table attribute for newly created data column" do
          table_schema.col :office_code, type: :string
          expect(table_schema.columns.last.table).to be table_schema

          table_schema.col :ref => 'ref.risk_tolerance'
          expect(table_schema.columns.last.table).to be table_schema

          table_schema.col :ref => :investment_time_horizon, schema: :ref
          expect(table_schema.columns.last.table).to be table_schema
        end
      end


      describe '#timestamps' do
        it "creates 5 new data column schema instances" do
          column_schema = DataColumnSchema.new(:office_code, table: 'master_accounts')
          expect(DataColumnSchema).to receive(:new).at_least(5).times.and_return(column_schema)
          table_schema.timestamps
        end

        it "adds 5 new column schema instances to columns collection" do
          expect { table_schema.timestamps }.to change { table_schema.columns.count }.by(5)
        end

        context "with default date naming convention" do
          it { expect_added_columns(:created_at, :modified_at) { table_schema.timestamps }}
        end

        context "with 'short' date naming convention" do
          it { expect_added_columns(:created, :modified) { table_schema.timestamps dates: :short }}
        end

        context "with default naming convention for string columns" do
          it { expect_added_columns(:created_by, :modified_by) { table_schema.timestamps }}
        end

        context "with 'snake' column naming convention for string columns" do
          it { expect_added_columns(:createdBy, :modifiedBy) { table_schema.timestamps naming: :camel }}
        end
      end


      describe '#index' do
        subject(:index) { table.indexes.first }

        it "creates a new index" do
          expect(Gauge::DB::Index).to receive(:new).with('idx_dbo_master_accounts_rep_code',
            hash_including(table: 'dbo.master_accounts', columns: :rep_code, clustered: true))
          table_schema.col :rep_code
          table_schema.index :rep_code, clustered: true
        end

        it "adds a new index to indexes collection" do
          index = double('index')
          Gauge::DB::Index.stub(:new).and_return(index)
          table_schema.col :rep_code
          expect { table_schema.index :rep_code }.to change { table_schema.indexes.count }.by(1)
          expect(table_schema.indexes).to include(index)
        end

        context "for a regular one column index" do
          let(:table) do
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
              DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code
                col :rep_name
                index [:rep_code, :office_code]
              end
            }.to raise_error(InvalidMetadataError, /missing column 'office_code' in bnr.reps data table/i)
          end
        end
      end


      describe '#unique' do
        subject { table.unique_constraints.first }

        it "creates a new unique constraint" do
          expect(Gauge::DB::Constraints::UniqueConstraint).to receive(:new).with('uc_dbo_master_accounts_rep_code',
            hash_including(table: 'dbo.master_accounts', columns: :rep_code))
          table_schema.col :rep_code
          table_schema.unique :rep_code
        end

        it "adds a new unique constraint to the unique constraints collection" do
          unique_constraint = double('unique_constraint')
          Gauge::DB::Constraints::UniqueConstraint.stub(:new).and_return(unique_constraint)
          table_schema.col :rep_code
          expect { table_schema.unique :rep_code }.to change { table_schema.unique_constraints.count }.by(1)
          table_schema.unique_constraints.should include(unique_constraint)
        end

        context "for a regular unique constraint defined on one column" do
          let(:table) do
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
              DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
                col :rep_code
                col :rep_name
                unique [:rep_code, :office_code]
              end
            }.to raise_error(InvalidMetadataError, /missing column 'office_code' in bnr.reps data table/i)
          end
        end
      end


      describe '#primary_key' do
        subject { table.primary_key }

        it { expect(table_schema.primary_key).to_not be nil }
        it { expect(table_schema.primary_key).to be_a DB::Constraints::PrimaryKeyConstraint }

        it "returns the same object instance" do
          key = table_schema.primary_key
          expect(table_schema.primary_key).to be_equal(key)
          expect(key).to be_equal(table_schema.primary_key)
        end

        context "when a primary key defined by convention" do
          subject { table_schema.primary_key }

          it { expect(table_schema.primary_key.columns).to have(1).column }
          it_behaves_like "a primary key", name: 'pk_dbo_master_accounts', table: :dbo_master_accounts, column: :id
          it { expect(table_schema.primary_key).to be_clustered }
        end

        context "when a primary key defined using :id attribute" do
          let(:table) do
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
            DataTableSchema.new(:source_firms, sql_schema: :ref, db: :test_db) do
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
            DataTableSchema.new(:account_owners, db: :test_db) do
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
            DataTableSchema.new(:reps, db: :test_db) do
              col :rep_id, id: true
              col :rep_code, business_id: true
            end
          end

          it { expect(table.primary_key.columns).to include :rep_id }
          it { expect(table.primary_key).to_not be_clustered }
        end

        context "when a clustered index defined" do
          let(:table) do
            DataTableSchema.new(:reps, db: :test_db) do
              col :rep_id, id: true
              col :rep_code, index: { clustered: true }
            end
          end

          it { expect(table.primary_key.columns).to include :rep_id }
          it { expect(table.primary_key).to_not be_clustered }
        end

        context "when a composite clustered index defined" do
          let(:table) do
            DataTableSchema.new(:fund_accounts, db: :test_db) do
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

        it { expect(table_schema.indexes).to_not be nil }

        context "when no indexes defined" do
          it { expect(table_schema.indexes).to be_empty }
        end

        context "when one index is defined" do
          let(:table) do
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
            DataTableSchema.new(:trades, db: :test_db) do
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
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
              DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
              DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
              DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
              DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
              DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
              DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
              DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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
              DataTableSchema.new(:fund_accounts, db: :test_db) do
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


      describe '#unique_constraints' do
        subject { table.unique_constraints.first }

        it { expect(table_schema.unique_constraints).to_not be nil }

        context "when no unique constraints defined" do
          it { expect(table_schema.unique_constraints).to be_empty }
        end

        context "when one unique constraint defined" do
          let(:table) do
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
              col :rep_code, unique: true
            end
          end

          it { expect(table.unique_constraints).to have(1).item }
          it_behaves_like "a unique constraint", name: 'uc_bnr_reps_rep_code',
            table: :bnr_reps, column: :rep_code
        end

        context "when multiple unique constraints defined" do
          let(:table) do
            DataTableSchema.new(:trades, db: :test_db) do
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
            DataTableSchema.new(:reps, sql_schema: :bnr, db: :test_db) do
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


      describe '#foreign_keys' do
        subject { table.foreign_keys.first }

        it { expect(table_schema.foreign_keys).to_not be_nil }

        context "when no foreign keys defined" do
          it { expect(table_schema.foreign_keys).to be_empty }
        end

        context "when one foreign key defined" do
          let(:table) do
            DataTableSchema.new(:trades, sql_schema: :bnr, db: :test_db) do
              col :ref => 'bnr.products'
            end
          end

          it { expect(table.foreign_keys).to have(1).item }
          it_behaves_like "a foreign key constraint", name: 'fk_bnr_trades_bnr_products_product_id',
            table: :bnr_trades, column: :product_id, ref_table: :bnr_products, ref_column: :id
        end

        context "when multiple foreign keys defined" do
          let(:table) do
            DataTableSchema.new(:trades, sql_schema: :bnr, db: :test_db) do
              col :rep_code, :ref => { table: :reps, column: :code }
              col :ref => 'bnr.products'
            end
          end

          it { expect(table.foreign_keys).to have(2).items }
          it_behaves_like "a foreign key constraint", name: 'fk_bnr_trades_dbo_reps_rep_code',
            table: :bnr_trades, column: :rep_code, ref_table: :dbo_reps, ref_column: :code
        end

        context "when a composite foreign key is defined" do
        end
      end


      describe '#cleanup_sql_files' do
        it "deletes all SQL migration files belong to a data table" do
          expect(FileUtils).to receive(:remove_file).with(/\/sql\/test_db\/tables\/create_dbo_master_accounts.sql/,
            hash_including(force: true)).once
          expect(FileUtils).to receive(:remove_file).with(/\/sql\/test_db\/tables\/alter_dbo_master_accounts.sql/,
            hash_including(force: true)).once
          table_schema.cleanup_sql_files
        end
      end


  private

      def expect_added_columns(*columns)
        expect(table_schema).to_not contain_columns(columns)
        yield
        expect(table_schema).to contain_columns(columns)
      end
    end
  end
end
