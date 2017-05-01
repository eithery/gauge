# Eithery Lab, 2017
# Gauge::Schema::DataColumnSchema specs

require 'spec_helper'

module Gauge
  module Schema
    describe DataColumnSchema do

      let(:column) { DataColumnSchema.new(name: :rep_code, table: reps) }
      let(:reps) { DataTableSchema.new(name: :reps, sql_schema: :bnr, db: :test_db) }

      subject { column }

      it { should respond_to :table, :table_schema }
      it { should respond_to :column_id, :column_name }
      it { should respond_to :column_type, :data_type, :sql_type }
      it { should respond_to :id?, :business_id? }
      it { should respond_to :length }
      it { should respond_to :char_column? }
      it { should respond_to :allow_null? }
      it { should respond_to :default_value, :sql_default_value }
      it { should respond_to :sql_attributes }
      it { should respond_to :to_sym, :to_s }
      it { should respond_to :has_index?, :index }
      it { should respond_to :has_unique_constraint?, :unique_constraint }
      it { should respond_to :has_foreign_key?, :foreign_key }
      it { should respond_to :computed? }
      it { should respond_to :bool? }


      describe '#initialize' do
        it "raises an error for not supported column types" do
          expect { DataColumnSchema.new(name: :customers, type: :unknown) }
            .to raise_error(ArgumentError, /invalid column type/i)
        end
      end


      describe '#table' do
        context "when a column schema is created within a data table schema" do
          before { reps.col :rep_code, len: 10 }
          it { expect(reps.columns.last.table).to be reps }
        end

        context "when a column schema is created explicitly" do
          it { expect(DataColumnSchema.new(name: :account_number, table: reps).table).to be reps }
          it { expect(DataColumnSchema.new(name: :account_number).table).to be nil }
        end
      end


      describe '#table_schema' do
        it "is alias for #table method" do
          expect(column.table_schema).to be column.table
          expect(column.table_schema).to_not be nil
        end
      end


      describe '#column_id' do
        it "returns a column name converted to a symbol" do
          expect(column.column_id).to be :rep_code
          ref_column = DataColumnSchema.new(:ref => :primary_reps)
          expect(ref_column.column_id).to be :primary_rep_id
        end
      end


      describe '#to_sym' do
        it "always returns column_id" do
          ref_column = DataColumnSchema.new(:ref => :primary_reps)
          expect(column.to_sym).to be column.column_id
          expect(ref_column.to_sym).to be ref_column.column_id
          expect(column.to_sym).to_not be nil
          expect(ref_column.to_sym).to_not be nil
        end
      end


      describe '#column_name' do
        context "when a name is explicitly passed in constructor arguments" do
          it { expect(column.column_name).to eq 'rep_code' }
          it { expect(DataColumnSchema.new(name: 'AccountNumber').column_name).to eq 'AccountNumber' }
        end

        context "when no name passed in constructor args" do
          context "and column attributes contain a ref to another table" do
            it "concludes a column name based on the ref" do
              ref_column = DataColumnSchema.new(:ref => 'bnr.primary_reps')
              expect(ref_column.column_name).to eq 'primary_rep_id'
              ref_column2 = DataColumnSchema.new(:ref => { table: :risk_tolerance, schema: :bnr })
              expect(ref_column2.column_name).to eq 'risk_tolerance_id'
            end
          end

          context "and column is defined as id" do
            it "interprets the column name as id" do
              id_column = DataColumnSchema.new(id: true)
              expect(id_column.column_name).to eq 'id'
            end
          end

          context "and no refs to another table defined" do
            it "raises an error" do
              expect { DataColumnSchema.new.column_name }
                .to raise_error(ArgumentError, /column name is not specified/i)
            end
          end
        end
      end


      describe '#column_type' do
        context "when a type is explicitly passed in constructor args" do
          it "returns initialized column type converted to a symbol" do
            string_column = DataColumnSchema.new(name: 'name', type: 'string')
            expect(string_column.column_type).to be :string
            country_column = DataColumnSchema.new(name: :customers, type: :country)
            expect(country_column.column_type).to be :country
            bool_column = DataColumnSchema.new(name: 'active', type: 'BOOL')
            expect(bool_column.column_type).to be :bool
          end
        end

        context "when no type attribute is defined" do
          context "and column attributes contain the ref to another table" do
            context "and no column length defined" do
              let(:ref_column) { DataColumnSchema.new(:ref => :reps) }
              it { expect(ref_column.column_type).to be :id }
            end

            context "and a column length is defined" do
              let(:ref_column) { DataColumnSchema.new(name: :rep_code, len: 10, :ref => :reps) }
              it { expect(ref_column.column_type).to be :string }
            end
          end

          context "and a column is defined as a surrogate id" do
            context "and no column length defined" do
              let(:id_column) { DataColumnSchema.new(name: :master_account_id, id: true) }
              it { expect(id_column.column_type).to be :id }
            end

            context "and a column length is defined" do
              let(:id_column) { DataColumnSchema.new(name: :batch_code, len: 10, id: true) }
              it { expect(id_column.column_type).to be :string }
            end
          end

          context "and a column name contains 'is', 'has', or 'allow' prefix" do
            let(:bool_columns) do
              ['is_visible', 'has_accounts', 'allow_delete'].map do |col_name|
                DataColumnSchema.new(name: col_name)
              end
            end
            it "is expected to be boolean" do
              bool_columns.each { |col| expect(col.column_type).to be :bool }
            end
          end

          context "and a column name contains 'date' or '_at' suffix" do
            let(:date_time_columns) do
              ['startDate', 'created_at'].map do |col_name|
                DataColumnSchema.new(name: col_name)
              end
            end
            it "is expected to be datetime" do
              date_time_columns.each { |col| expect(col.column_type).to be :datetime }
            end
          end

          context "and a column name contains '_on' suffix" do
            let(:date_column) { DataColumnSchema.new(name: :created_on) }
            it { expect(date_column.column_type).to be :date }
          end

          context "and a column name does not contain specific prefixes or suffixes" do
            let(:string_column) { DataColumnSchema.new(name: :account_number) }
            it { expect(string_column.column_type).to be :string }
          end
        end
      end


      describe '#data_type' do
        it "supports convertion from the specified column type" do
          expect([:long, :id]).to be_converted_to :bigint
          expect(:int).to be_converted_to :int
          expect(:short).to be_converted_to :smallint
          expect(:string).to be_converted_to :nvarchar
          expect([:char, :us_state, :country]).to be_converted_to :nchar
          expect([:bool, :byte, :enum]).to be_converted_to :tinyint
          expect(:datetime).to be_converted_to :datetime
          expect(:date).to be_converted_to :date
          expect([:money, :percent]).to be_converted_to :decimal
          expect(:xml).to be_converted_to :xml
          expect(:blob).to be_converted_to :varbinary
          expect(:binary).to be_converted_to :binary
          expect(:guid).to be_converted_to :uniqueidentifier
        end

        context "when a data column is a surrogate primary key" do
          let(:id_column) { DataColumnSchema.new(id: true, table: table) }

          context "for a regular data table" do
            let(:table) { DataTableSchema.new(name: :customers, db: :test_db) }
            it { expect(id_column.data_type).to be :bigint }
          end

          context "for a reference data table containing metadata" do
            context "defined explicitly" do
              let(:table) { DataTableSchema.new(name: :activation_reasons, table_type: :reference, db: :test_db) }
              it { expect(id_column.data_type).to be :tinyint }
            end

            context "defined based on the table SQL schema" do
              let(:table) { DataTableSchema.new(name: :risk_tolerance, sql_schema: :ref, db: :test_db) }
              it { expect(id_column.data_type).to be :tinyint }
            end
          end
        end

        context "when a data column represents a foreign key reference" do
          context "to ref data table" do
            context "defined explicitly" do
              let(:ref_column) { DataColumnSchema.new(:ref => { table: :risk_tolerance, schema: :ref }) }
              it { expect(ref_column.data_type).to be :tinyint }
            end

            context "defined by ref table name" do
              let(:ref_column) { DataColumnSchema.new(:ref => 'ref.risk_tolerance') }
              it { expect(ref_column.data_type).to be :tinyint }
            end
          end

          context "to a regular data table" do
            context "when a table name is defined as a symbol" do
              let(:ref_column) { DataColumnSchema.new(:ref => :reps) }
              it { expect(ref_column.data_type).to be :bigint }
            end

            context "when a table name is defined as a string" do
              let(:ref_column) { DataColumnSchema.new(:ref => 'exp.reps') }
              it { expect(ref_column.data_type).to be :bigint }
            end
          end
        end
      end


      describe '#sql_type' do
        context "for character types" do
          it { expect(DataColumnSchema.new(name: :account_number).sql_type).to eq 'nvarchar(255)' }
          it { expect(DataColumnSchema.new(name: :rep_code, len: 10).sql_type).to eq 'nvarchar(10)' }
          it { expect(DataColumnSchema.new(name: :service_flag, type: :char).sql_type).to eq 'nchar(1)' }
        end

        context "for money type" do
          it { expect(DataColumnSchema.new(name: :total_amount, type: :money).sql_type).to eq 'decimal(18,2)' }
        end

        context "for percent type" do
          it { expect(DataColumnSchema.new(name: :bank_rate, type: :percent).sql_type).to eq 'decimal(18,4)' }
        end

        context "for blob type" do
          it { expect(DataColumnSchema.new(name: :image, type: :blob).sql_type).to eq 'varbinary(max)' }
        end

        context "for binary type" do
          it { expect(DataColumnSchema.new(name: :hash_code, type: :binary, len: 10).sql_type).to eq 'binary(10)' }
        end

        context "for id types" do
          it { expect(DataColumnSchema.new(id: true).sql_type).to eq 'bigint' }
          it { expect(DataColumnSchema.new(:ref => 'ref.financial_info').sql_type).to eq 'tinyint' }
        end

        context "for other types" do
          it { expect(DataColumnSchema.new(name: :status, type: :enum).sql_type).to eq 'tinyint' }
          it { expect(DataColumnSchema.new(name: :created_at).sql_type).to eq 'datetime' }
          it { expect(DataColumnSchema.new(name: :country, type: :country).sql_type).to eq 'nchar(2)' }
          it { expect(DataColumnSchema.new(name: :state_code, type: :us_state).sql_type).to eq 'nchar(2)' }
          it { expect(DataColumnSchema.new(name: :is_active).sql_type).to eq 'tinyint' }
          it { expect(DataColumnSchema.new(name: :snapshot, type: :xml).sql_type).to eq 'xml' }
          it { expect(DataColumnSchema.new(name: :trageGuid, type: :guid).sql_type).to eq 'uniqueidentifier' }
        end
      end


      describe '#length' do
        context "when a column length is defined in metadata" do
          context "as an integer value" do
            let(:column) { DataColumnSchema.new(name: :rep_code, len: 10) }
            it "equals to the passed length value" do
              expect(column.length).to eq 10
            end
          end

          context "as a maximum available value" do
            let(:column) { DataColumnSchema.new(name: :description, len: :max) }
            it { expect(column.length).to be :max }
          end
        end

        context "when no column length defined" do
          context "for string columns" do
            let(:column) { DataColumnSchema.new(name: :last_name, type: :string) }
            it { expect(column.length).to eq DataColumnSchema::DEFAULT_VARCHAR_LENGTH }
          end

          context "for char columns" do
            let(:column) { DataColumnSchema.new(name: :trade_type, type: :char) }
            it { expect(column.length).to eq DataColumnSchema::DEFAULT_CHAR_LENGTH }
          end

          context "for country code columns" do
            let(:column) { DataColumnSchema.new(name: :country_code, type: :country) }
            it { expect(column.length).to eq DataColumnSchema::DEFAULT_ISO_CODE_LENGTH }
          end

          context "for US state code columns" do
            let(:column) { DataColumnSchema.new(name: :state_code, type: :us_state) }
            it { expect(column.length).to eq DataColumnSchema::DEFAULT_ISO_CODE_LENGTH }
          end

          context "for other column types" do
            let(:column) { DataColumnSchema.new(name: :created, type: :datetime) }
            it { expect(column.length).to be nil }
          end
        end
      end


      describe '#char_column?' do
        it "returns true when a column type is one of the character types" do
          [:string, :char, :us_state, :country].map { |t| DataColumnSchema.new(name: :col_name, type: t) }
            .each { |col| expect(col.char_column?).to be true }
        end

        it "returns false when a column type is not a character type" do
          [:id, :long, :datetime, :money, :enum].map { |t| DataColumnSchema.new(name: :col_name, type: t) }
            .each { |col| expect(col.char_column?).to be false }
        end
      end


      describe '#allow_null?' do
        it "returns true when no identity or required attributes defined" do
          expect(DataColumnSchema.new(name: :account_number).allow_null?).to be true
        end

        it "returns false when a column is defined as an identity column" do
          expect(DataColumnSchema.new(id: true).allow_null?).to be false
        end

        it "returns false when a column defined as a business identity column" do
          expect(DataColumnSchema.new(business_id: true).allow_null?).to be false
        end

        it "returns false when a column is defined as required" do
          expect(DataColumnSchema.new(required: true).allow_null?).to be false
        end
      end


      describe '#default_value' do
        context "when defined explicitly in column attributes" do
          context "for enumeration (integer) data columns" do
            let(:column) { DataColumnSchema.new(name: :account_status, required: true, default: 1) }
            it { expect(column.default_value).to be 1 }
          end

          context "for boolean data columns" do
            let(:column) { DataColumnSchema.new(name: :is_active, required: true, default: true) }
            it { expect(column.default_value).to be true }
          end

          context "as UID" do
            let(:column) { DataColumnSchema.new(name: :account_id, id: true, default: :uid) }
            it { expect(column.default_value).to eq DataColumnSchema::UID }
          end

          context "as SQL function without arguments" do
            let(:column) { DataColumnSchema.new(name: :modified_by, default: { function: :host_name }) }
            it { expect(column.default_value).to eq 'host_name()' }
          end

          context "as CURRENT_TIMESTAMP SQL function" do
            let(:column) { DataColumnSchema.new(name: :modified_at, default: { function: :current_timestamp }) }
            it { expect(column.default_value).to be :current_timestamp }
          end

          context "as getdate() SQL function" do
            let(:column) { DataColumnSchema.new(name: :modified_at, default: { function: :getdate }) }
            it { expect(column.default_value).to be :current_timestamp }
          end
        end

        context "when it is not defined in column attributes" do
          context "for boolean required columns" do
            let(:column) { DataColumnSchema.new(name: :is_restricted, required: true) }
            it { expect(column.default_value).to be false }
          end

          context "for other columns" do
            let(:column) { DataColumnSchema.new(name: :rep_code) }
            it { expect(column.default_value).to be nil }
            it { expect(DataColumnSchema.new(name: 'active', type: :bool).default_value).to be nil }
          end
        end
      end


      describe '#sql_default_value' do
        it "returns nil if no default value defined" do
          column = DataColumnSchema.new(name: :trade_id, :ref => :trades)
          expect(column.sql_default_value).to be nil
        end

        it "returns a quoted default value for character types" do
          expect(DataColumnSchema.new(name: :rep_code, default: 'R001').sql_default_value).to eq "'R001'"
          expect(DataColumnSchema.new(name: :country, type: :country, default: 'US').sql_default_value).to eq "'US'"
        end

        it "returns 0 and 1 respectively for boolean types" do
          expect(DataColumnSchema.new(name: :is_active, default: true).sql_default_value).to be 1
          expect(DataColumnSchema.new(name: :is_active, required: true).sql_default_value).to be 0
        end

        it "returns an unchanged default value for other column types" do
          column = DataColumnSchema.new(name: :created_at, default: { function: :getdate })
          expect(column.sql_default_value).to be :current_timestamp
          expect(DataColumnSchema.new(name: :status, type: :enum, default: 2).sql_default_value).to eq 2
          expect(DataColumnSchema.new(name: :total_amount, type: :money, default: 120.32).sql_default_value).to eq 120.32
        end
      end


      describe '#sql_attributes' do
        it "returns a column type, length, and nullability as a part of SQL clause" do
          columns.each do |col|
            column = DataColumnSchema.new(col.first)
            expect(column.sql_attributes).to eq col.last
          end
        end
      end


      describe '#id?' do
        it "returns true when a column schema defines a surrogate id" do
          column = DataColumnSchema.new(name: :rep_id, table: reps, id: true)
          expect(column.id?).to be true
        end

        it "returns false when no surrogate id defined" do
          column = DataColumnSchema.new(name: :rep_id, table: reps)
          expect(column.id?).to be false
        end

        it "returns false when id option value is not true" do
          column = DataColumnSchema.new(name: :rep_id, table: reps, id: false)
          expect(column.id?).to be false
          column = DataColumnSchema.new(name: :rep_id, table: reps, id: 'true')
          expect(column.id?).to be false
        end
      end


      describe '#business_id?' do
        it "returns true when a column schema defines a business id" do
          column = DataColumnSchema.new(name: :rep_code, table: reps, business_id: true)
          expect(column.business_id?).to be true
        end

        it "returns false when no business id defined" do
          column = DataColumnSchema.new(name: :rep_code, table: reps)
          expect(column.business_id?).to be false
        end

        it "returns false when a business_id value is not true" do
          column = DataColumnSchema.new(name: :rep_code, table: reps, business_id: false)
          expect(column.business_id?).to be false
          column = DataColumnSchema.new(name: :rep_code, table: reps, business_id: 'true')
          expect(column.business_id?).to be false
        end
      end


      describe '#bool?' do
        let(:bool_columns) do [
          DataColumnSchema.new(name: :active, type: :bool),
          DataColumnSchema.new(name: :is_active),
          DataColumnSchema.new(name: :has_participants),
          DataColumnSchema.new(name: :allow_delete)
        ]
        end
        let(:other_columns) do [
          DataColumnSchema.new(name: :code),
          DataColumnSchema.new(name: :created_at),
          DataColumnSchema.new(name: :is_active, type: :enum)
        ]
        end

        it "returns true for boolean data columns" do
          bool_columns.each { |col| expect(col.bool?).to be true }
        end

        it "returns false for all other column types" do
          other_columns.each { |col| expect(col.bool?).to be false }
        end
      end


      describe '#has_index?' do
        it "returns true when a column schema defines an index" do
          expect(DataColumnSchema.new(name: :rep_code, index: true).has_index?).to be true
          expect(DataColumnSchema.new(name: :rep_code, index: { unique: true }).has_index?).to be true
        end

        it "returns false when an index is not defined" do
          expect(DataColumnSchema.new(name: :rep_code, index: false).has_index?).to be false
          expect(DataColumnSchema.new(name: :rep_code).has_index?).to be false
        end
      end


      describe '#index' do
        context "when a column schema defines an index" do
          shared_examples_for "rep code index" do
            it { expect(column.index).to be_a Gauge::DB::Index }
            it { expect(column.index.name).to eq 'idx_bnr_reps_rep_code' }
            it { expect(column.index.table).to eq reps.to_sym }
            it { expect(column.index.columns).to include(:rep_code) }
            it { expect(column.index.columns).to have(1).item }
            it { expect(column.index).to_not be_composite }
          end

          context "with 'true' value" do
            let(:column) { DataColumnSchema.new(name: :rep_code, table: reps, index: true) }
            it_behaves_like "rep code index"
            it { expect(column.index).to_not be_clustered }
            it { expect(column.index).to_not be_unique }
          end

          context "with 'false' value" do
            let(:column) { DataColumnSchema.new(name: :rep_code, table: reps, index: false) }
            it { expect(column.index).to be nil }
          end

          context "with 'unique' attribute" do
            let(:column) { DataColumnSchema.new(name: :rep_code, table: reps, index: { unique: true }) }
            it_behaves_like "rep code index"
            it { expect(column.index).to_not be_clustered }
            it { expect(column.index).to be_unique }
          end

          context "with 'clustered' attribute" do
            let(:column) { DataColumnSchema.new(name: :rep_code, table: reps, index: { clustered: true }) }
            it_behaves_like "rep code index"
            it { expect(column.index).to be_clustered }
            it { expect(column.index).to be_unique }
          end
        end

        context "when an index is not defined" do
          let(:column) { DataColumnSchema.new(name: :rep_code) }
          it { expect(column.index).to be nil }
        end
      end


      describe '#has_unique_constraint?' do
        it "returns true when a column schema defines a unique constraint" do
          expect(DataColumnSchema.new(name: :rep_code, unique: true).has_unique_constraint?).to be true
        end

        it "returns false when a unique constraint is not defined" do
          expect(DataColumnSchema.new(name: :rep_code).has_unique_constraint?).to be false
          expect(DataColumnSchema.new(name: :rep_code, unique: false).has_unique_constraint?).to be false
        end
      end


      describe '#unique_constraint' do
        context "when a column schema defines a unique constraint" do
          shared_examples_for "rep code unique constraint" do
            it { expect(column.unique_constraint).to be_a Gauge::DB::Constraints::UniqueConstraint }
            it { expect(column.unique_constraint.name).to eq 'uc_bnr_reps_rep_code' }
            it { expect(column.unique_constraint.table).to eq reps.to_sym }
            it { expect(column.unique_constraint.columns).to include :rep_code }
            it { expect(column.unique_constraint.columns).to have(1).item }
            it { expect(column.unique_constraint).to_not be_composite }
          end

          context "with 'true' value" do
            let(:column) { DataColumnSchema.new(name: :rep_code, table: reps, unique: true) }
            it_behaves_like "rep code unique constraint"
          end

          context "with 'false' value" do
            let(:column_schema) { DataColumnSchema.new(name: :rep_code, table: reps, unique: false) }
            it { expect(column.unique_constraint).to be nil }
          end
        end

        context "when a unique constraint is not defined" do
          let(:column) { DataColumnSchema.new(name: :rep_code, table: reps) }
          it { expect(column.unique_constraint).to be nil }
        end
      end


      describe '#has_foreign_key?' do
        context "when a column schema defines a foreign key" do
          context "with default SQL schema" do
            it { expect(DataColumnSchema.new(:ref => :offices).has_foreign_key?).to be true }
          end

          context "with custom SQL schema combined with ref table name" do
            it { expect(DataColumnSchema.new(:ref => 'bnr.offices').has_foreign_key?).to be true }
          end

          context "with custom SQL schema defined using a hash based options" do
            let(:column) { DataColumnSchema.new(:ref => { table: :offices, sql_schema: :bnr }) }
            it { expect(column.has_foreign_key?).to be true }
          end

          context "with ref to custom data column" do
            let(:column) { DataColumnSchema.new(:ref => { table: :offices, column: :office_code }) }
            it { expect(column.has_foreign_key?).to be true }
          end
        end

        context "when a foreign key is not defined" do
          it { expect(DataColumnSchema.new(name: :rep_code).has_foreign_key?).to be false }
        end
      end


      describe '#foreign_key' do
        context "when a column schema defines a foreign key" do
          shared_examples_for "foreign key constraint" do
            it { expect(column.foreign_key).to be_a Gauge::DB::Constraints::ForeignKeyConstraint }
            it { expect(column.foreign_key.table).to eq reps.to_sym }
            it { expect(column.foreign_key.columns).to have(1).item }
            it { expect(column.foreign_key.ref_columns).to have(1).column }
            it { expect(column.foreign_key).to_not be_composite }
          end

          context "with default SQL schema" do
            let(:column) { DataColumnSchema.new(:ref => :offices, table: reps) }

            it_behaves_like "foreign key constraint"
            it { expect(column.foreign_key.name).to eq 'fk_bnr_reps_dbo_offices_office_id' }
            it { expect(column.foreign_key.columns).to include :office_id }
            it { expect(column.foreign_key.ref_table).to be :dbo_offices }
            it { expect(column.foreign_key.ref_columns).to include :id }
          end

          context "with custom SQL schema combined with ref table name" do
            let(:column) { DataColumnSchema.new(:ref => 'bnr.offices', table: reps) }

            it_behaves_like "foreign key constraint"
            it { expect(column.foreign_key.name).to eq 'fk_bnr_reps_bnr_offices_office_id' }
            it { expect(column.foreign_key.columns).to include :office_id }
            it { expect(column.foreign_key.ref_table).to be :bnr_offices }
            it { expect(column.foreign_key.ref_columns).to include :id }
          end

          context "with custom SQL schema defined using a hash based option" do
            let(:column) { DataColumnSchema.new(:ref => { table: :offices, schema: :bnr }, table: reps) }

            it_behaves_like "foreign key constraint"
            it { expect(column.foreign_key.name).to eq 'fk_bnr_reps_bnr_offices_office_id' }
            it { expect(column.foreign_key.columns).to include :office_id }
            it { expect(column.foreign_key.ref_table).to be :bnr_offices }
            it { expect(column.foreign_key.ref_columns).to include :id }
          end

          context "with ref to a custom data column" do
            let(:column) do
              DataColumnSchema.new(name: :office_code, :ref => { table: :offices, column: :office_code }, table: reps)
            end

            it_behaves_like "foreign key constraint"
            it { expect(column.foreign_key.name).to eq 'fk_bnr_reps_dbo_offices_office_code' }
            it { expect(column.foreign_key.columns).to include :office_code }
            it { expect(column.foreign_key.ref_table).to be :dbo_offices }
            it { expect(column.foreign_key.ref_columns).to include :office_code }
          end
        end

        context "when a foreign key is not defined" do
          it { expect(DataColumnSchema.new(name: :rep_code).foreign_key).to be nil }
        end
      end


      describe '#computed?' do
        it "returns false for regular columns" do
          expect(DataColumnSchema.new(name: :rep_code, len: 10).computed?).to be false
        end

        it "returns true for computed columns" do
          computed_column = DataColumnSchema.new(name: :source_firm_code, computed: { function: :get_source_code })
          expect(computed_column.computed?).to be true
        end
      end


      describe '#to_s' do
        it "returns a column schema string representation" do
          columns.each do |col|
            column = DataColumnSchema.new(col.first)
            expect(column.to_s).to eq "Column #{column.column_name} #{col.last}"
          end
        end
      end


  private

      def columns
        @columns ||= [
          [{ name: :last_name },                                         'nvarchar(255) null'],
          [{ name: :rep_code, len: 10 },                                 'nvarchar(10) null'],
          [{ name: :description, len: :max },                            'nvarchar(max) null'],
          [{ name: :total_amount, type: :money },                        'decimal(18,2) null'],
          [{ name: :rate, type: :percent, required: true },              'decimal(18,4) not null'],
          [{ name: :state_code, type: :us_state },                       'nchar(2) null'],
          [{ name: :country, type: :country, required: true },           'nchar(2) not null'],
          [{ name: :service_flag, type: :char },                         'nchar(1) null'],
          [{ name: :account_id, id: true },                              'bigint not null'],
          [{ name: :total_years, type: :int, required: true },           'int not null'],
          [{ id: true },                                                 'bigint not null'],
          [{ :ref => :primary_reps },                                    'bigint null'],
          [{ :ref => 'ref.financial_info' },                             'tinyint null'],
          [{ name: :created_at },                                        'datetime null'],
          [{ name: :created_on, required: true },                        'date not null'],
          [{ name: :snapshot, type: :xml },                              'xml null'],
          [{ name: :photo, type: :blob, required: true },                'varbinary(max) not null'],
          [{ name: :hash_code, type: :binary, len: 10, required: true }, 'binary(10) not null'],
          [{ name: :is_active },                                         'tinyint null'],
          [{ name: :status, type: :short, required: true },              'smallint not null'],
          [{ name: :risk_tolerance, type: :enum, required: true },       'tinyint not null'],
          [{ name: :trade_guid, type: :guid },                           'uniqueidentifier null']
        ]
      end
    end
  end
end
