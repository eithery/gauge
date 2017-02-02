# Eithery Lab, 2017
# Gauge::Schema::DataColumnSchema specs

require 'spec_helper'

module Gauge
  module Schema
    describe DataColumnSchema, f: true do
      let(:column) { DataColumnSchema.new(:account_number, type: :string, required: true) }
      let(:ref_column) { DataColumnSchema.new(:ref => 'br.primary_reps') }
      let(:id_column) { DataColumnSchema.new(id: true) }
      let(:table_schema) { DataTableSchema.new(:reps, sql_schema: :bnr) }

      subject { column }

      it { should respond_to :column_name }
      it { should respond_to :column_type, :data_type, :sql_type }
      it { should respond_to :table, :table_schema }
      it { should respond_to :length, :char_column? }
      it { should respond_to :allow_null?, :default_value, :sql_default_value }
      it { should respond_to :to_sym }
      it { should respond_to :id?, :business_id? }
      it { should respond_to :in_table }
      it { should respond_to :computed? }
      it { should respond_to :bool? }
      it { should respond_to :has_index?, :index }
      it { should respond_to :has_unique_constraint?, :unique_constraint }
      it { should respond_to :has_foreign_key?, :foreign_key }
      it { should respond_to :sql_attributes }


      describe '#initialize' do
        it "raises an error for not supported column types" do
          expect { DataColumnSchema.new(:customers, type: :unknown) }
            .to raise_error(ArgumentError, /invalid column type/i)
        end
      end


      describe '#table' do
        context "when a column schema is created by a data table schema" do
          before { table_schema.col :rep_code, len: 10 }
          it { expect(table_schema.columns.last.table).to be table_schema }
        end

        context "when a column schema is created explicitly" do
          it { expect(DataColumnSchema.new(:account_number).table).to be nil }
        end
      end


      describe '#table_schema' do
        let(:column_schema) { DataColumnSchema.new(:rep_code, :reps, required: true).in_table table_schema }
        it "is alias for #table method" do
          expect(column_schema.table_schema).to be column_schema.table
        end
      end


      describe '#column_name' do
        context "when a name is explicitly passed in constructor arguments" do
          it { expect(column.column_name).to eq 'account_number' }
        end

        context "when no name passed in constructor args" do
          context "and column attributes contain a ref to another table" do
            it "concludes a column name based on the ref" do
              expect(ref_column.column_name).to eq 'primary_rep_id'
              ref_column2 = DataColumnSchema.new(:ref => :risk_tolerance, schema: :ref)
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
              expect { DataColumnSchema.new.column_name }.to raise_error(ArgumentError, /column name is not specified/)
            end
          end
        end
      end


      describe '#column_type' do
        context "when a type is explicitly passed in constructor args" do
          let(:country_column) { DataColumnSchema.new(:customers, type: :country) }

          it "returns initialized column type converted to a symbol" do
            expect(column.column_type).to be :string
            expect(country_column.column_type).to be :country
          end
        end

        context "when no type attribute is defined" do
          context "and column attributes contain the ref to another table" do
            context "and no column length defined" do
              it { expect(ref_column.column_type).to be :id }
            end

            context "and a column length is defined" do
              let(:ref_column) { DataColumnSchema.new(:trade_type_code, len: 10, :ref => :trade_types) }
              it { expect(ref_column.column_type).to be :string }
            end
          end

          context "and a column is defined as a surrogate id" do
            context "and no column length defined" do
              let(:id_column) { DataColumnSchema.new(:master_account_id, id: true) }
              it { expect(id_column.column_type).to be :id }
            end

            context "and a column length is defined" do
              let(:id_column) { DataColumnSchema.new(:batch_code, len: 10, id: true) }
              it { expect(id_column.column_type).to be :string }
            end
          end

          context "and a column name contains 'is', 'has', or 'allow' prefix" do
            let(:bool_columns) do
              ['is_visible', 'has_accounts', 'allow_delete'].map do |col_name|
                DataColumnSchema.new(col_name)
              end
            end
            it "should be boolean" do
              bool_columns.each { |col| expect(col.column_type).to be :bool }
            end  
          end

          context "and a column name contains 'date' or '_at' suffix" do
            let(:date_time_columns) do
              ['startDate', 'created_at'].map do |col_name|
                DataColumnSchema.new(col_name)
              end
            end
            it "should be datetime" do
              date_time_columns.each { |col| expect(col.column_type).to be :datetime }
            end
          end

          context "and a column name contains '_on' suffix" do
            let(:column) { DataColumnSchema.new(:created_on) }
            it { expect(column.column_type).to be :date }
          end

          context "and a column name does not contain specific prefixes or suffixes" do
            let(:column) { DataColumnSchema.new(:account_number) }
            it { expect(column.column_type).to be :string }
          end
        end
      end


      describe '#sql_type' do
        context "for character types" do
          it { expect(DataColumnSchema.new(:account_number).sql_type).to eq 'nvarchar(255)' }
          it { expect(DataColumnSchema.new(:rep_code, len: 10).sql_type).to eq 'nvarchar(10)' }
          it { expect(DataColumnSchema.new(:service_flag, type: :char).sql_type).to eq 'nchar(1)' }
        end

        context "for money type" do
          it { expect(DataColumnSchema.new(:total_amount, type: :money).sql_type).to eq 'decimal(18,2)' }
        end

        context "for percent type" do
          it { expect(DataColumnSchema.new(:bank_rate, type: :percent).sql_type).to eq 'decimal(18,4)' }
        end

        context "for blob type" do
          it { expect(DataColumnSchema.new(:image, type: :blob).sql_type).to eq 'varbinary(max)' }
        end

        context "for binary type" do
          it { expect(DataColumnSchema.new(:hash_code, type: :binary, len: 10).sql_type).to eq 'binary(10)' }
        end

        context "for id types" do
          it { expect(DataColumnSchema.new(id: true).sql_type).to eq 'bigint' }
          it { expect(DataColumnSchema.new(:ref => 'ref.financial_info').sql_type).to eq 'tinyint' }
        end

        context "for other types" do
          it { expect(DataColumnSchema.new(:status, type: :enum).sql_type).to eq 'tinyint' }
          it { expect(DataColumnSchema.new(:created_at).sql_type).to eq 'datetime' }
          it { expect(DataColumnSchema.new(:country, type: :country).sql_type).to eq 'nchar(2)' }
          it { expect(DataColumnSchema.new(:state_code, type: :us_state).sql_type).to eq 'nchar(2)' }
          it { expect(DataColumnSchema.new(:is_active).sql_type).to eq 'tinyint' }
          it { expect(DataColumnSchema.new(:snapshot, type: :xml).sql_type).to eq 'xml' }
          it { expect(DataColumnSchema.new(:trageGuid, type: :guid).sql_type).to eq 'uniqueidentifier' }
        end
      end


      describe '#data_type' do
        it "supports convertion from the specified column type" do
          expect([:id, :long]).to be_converted_to :bigint
          expect(:int).to be_converted_to :int
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

        context "when a data column represents a surrogate primary key" do
          context "for a regular data table" do
            before { id_column.in_table DataTableSchema.new(:customers) }
            it { expect(id_column.data_type).to be :bigint }
          end

          context "for a reference data table containing metadata" do
            context "defined explicitly" do
              before { id_column.in_table DataTableSchema.new(:activation_reasons, table_type: :reference) }
              it { expect(id_column.data_type).to be :tinyint }
            end

            context "defined based on the table name" do
              before { id_column.in_table DataTableSchema.new(:risk_tolerance, sql_schema: :ref) }
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


      describe '#char_column?' do
        it "returns true when a column type is one of character types" do
          [:string, :char, :us_state, :country].map { |t| DataColumnSchema.new(:col_name, type: t) }
            .each { |col| expect(col.char_column?).to be true }
        end

        it "returns false when a column type is not character" do
          [:id, :long, :datetime, :money, :enum].map { |t| DataColumnSchema.new(:col_name, type: t) }
            .each { |col| expect(col.char_column?).to be false }
        end
      end


      describe '#allow_null?' do
        it "returns true when no identity or required attributes defined" do
          expect(DataColumnSchema.new(:account_number).allow_null?).to be true
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


      describe '#length' do
        context "when a column length is defined in metadata" do
          context "as an integer value" do
            let(:column) { DataColumnSchema.new(:rep_code, len: 10) }
            it "equals to the passed length value" do
              expect(column.length).to eq 10
            end
          end

          context "as a maximum available value" do
            let(:column) { DataColumnSchema.new(:description, len: :max) }
            it { expect(column.length).to be :max }
          end
        end

        context "when no column length defined" do
          context "for string columns" do
            let(:column) { DataColumnSchema.new(:last_name, type: :string) }
            it { expect(column.length).to eq DataColumnSchema::DEFAULT_VARCHAR_LENGTH }
          end

          context "for char columns" do
            let(:column) { DataColumnSchema.new(:trade_type, type: :char) }
            it { expect(column.length).to eq DataColumnSchema::DEFAULT_CHAR_LENGTH }
          end

          context "for country code columns" do
            let(:column) { DataColumnSchema.new(:country_code, type: :country) }
            it { expect(column.length).to eq DataColumnSchema::DEFAULT_ISO_CODE_LENGTH }
          end

          context "for US state code columns" do
            let(:column) { DataColumnSchema.new(:state_code, type: :us_state) }
            it { expect(column.length).to eq DataColumnSchema::DEFAULT_ISO_CODE_LENGTH }
          end

          context "for other column types" do
            let(:column) { DataColumnSchema.new(:created, type: :datetime) }
            it { expect(column.length).to be nil }
          end
        end
      end


      describe '#default_value' do
        context "when defined explicitly in column attributes" do
          context "for enumeration (integer) data columns" do
            let(:column) { DataColumnSchema.new(:account_status, required: true, default: 1) }
            it { expect(column.default_value).to be 1 }
          end

          context "for boolean data columns" do
            let(:column) { DataColumnSchema.new(:is_active, required: true, default: true) }
            it { expect(column.default_value).to be true }
          end

          context "as UID" do
            let(:column) { DataColumnSchema.new(:account_id, id: true, default: :uid) }
            it { expect(column.default_value).to eq DataColumnSchema::UID }
          end

          context "as SQL function without arguments" do
            let(:column) { DataColumnSchema.new(:modified_by, default: { function: :host_name }) }
            it { expect(column.default_value).to eq 'host_name()' }
          end

          context "as CURRENT_TIMESTAMP SQL function" do
            let(:column) { DataColumnSchema.new(:modified_at, default: { function: :current_timestamp }) }
            it { expect(column.default_value).to be :current_timestamp }
          end

          context "as getdate() SQL function" do
            let(:column) { DataColumnSchema.new(:modified_at, default: { function: :getdate }) }
            it { expect(column.default_value).to be :current_timestamp }
          end
        end

        context "when it is not defined in column attributes" do
          context "for boolean required columns" do
            let(:column) { DataColumnSchema.new(:is_restricted, required: true) }
            it { expect(column.default_value).to be false }
          end

          context "for other columns" do
            let(:column) { DataColumnSchema.new(:rep_code) }
            it { expect(column.default_value).to be nil }
          end
        end
      end


      describe '#sql_default_value' do
        it "returns nil if no default value defined" do
          column = DataColumnSchema.new(:trade_id, :ref => :trades)
          expect(column.sql_default_value).to be nil
        end

        it "returns a quoted default value for character types" do
          expect(DataColumnSchema.new(:rep_code, default: 'R001').sql_default_value).to eq "'R001'"
          expect(DataColumnSchema.new(:country, type: :country, default: 'US').sql_default_value).to eq "'US'"
        end

        it "returns 0 and 1 respectively for boolean types" do
          expect(DataColumnSchema.new(:is_active, default: true).sql_default_value).to be 1
          expect(DataColumnSchema.new(:is_active, required: true).sql_default_value).to be 0
        end

        it "returns an unchanged default value for other column types" do
          column = DataColumnSchema.new(:created_at, default: { function: :getdate })
          expect(column.sql_default_value).to be :current_timestamp
          DataColumnSchema.new(:status, type: :enum, default: 2).sql_default_value.should == 2
          DataColumnSchema.new(:total_amount, type: :money, default: 120.32).sql_default_value.should == 120.32
        end
      end


      describe '#sql_attributes' do
        it "returns column type, length, and nullability as part of SQL clause" do
          columns.each do |col|
            column = Schema::DataColumnSchema.new(col[0][0], col[0][1])
            column.sql_attributes.should == "#{col[1]}"
          end
        end
      end


      describe '#to_sym' do
        it "returns column name converted to a symbol" do
          column.to_sym.should == :account_number
        end
      end


      describe '#id?' do
        context "when column schema defines surrogate id" do
          before { @id_column = DataColumnSchema.new(:product_id, id: true) }
          specify { @id_column.should be_id }
        end

        context "when column schema does not define surrogate id" do
          before { @not_id_column = DataColumnSchema.new(:product_id) }
          specify { @not_id_column.should_not be_id }
        end

        context "when id option value is not true" do
          before { @not_id_column = DataColumnSchema.new(:product_id, product_id: false) }
          specify { @not_id_column.should_not be_id }
        end
      end


      describe '#business_id?' do
        context "when column schema defines business id" do
          before { @business_id_column = DataColumnSchema.new(:rep_code, business_id: true) }
          specify { @business_id_column.should be_business_id }
        end

        context "when column schema does not define business id" do
          before { @not_business_id_column = DataColumnSchema.new(:rep_code) }
          specify { @not_business_id_column.should_not be_business_id }
        end

        context "when business_id value is not true" do
          before { @not_business_id_column = DataColumnSchema.new(:rep_code, business_id: false) }
          specify { @not_business_id_column.should_not be_business_id }
        end
      end


      describe '#has_index?' do
        subject { @column.has_index? }

        context "when the column schema defines index" do
          context "with 'true' value" do
            before { @column = DataColumnSchema.new(:rep_code, index: true) }
            it { should be true }
          end

          context "with 'false' value" do
            before { @column = DataColumnSchema.new(:rep_code, index: false) }
            it { should be false }
          end

          context "with additional attributes" do
            before { @column = DataColumnSchema.new(:rep_code, index: { unique: true }) }
            it { should be true }
          end
        end

        context "when the column schema does not define index" do
          before { @column = DataColumnSchema.new(:rep_code) }
          it { should be false }
        end
      end


      describe '#index' do
        subject(:index) { @column.index }

        context "when the column schema defines index" do
          shared_examples_for "rep code index" do
            it { should be_a Gauge::DB::Index }
            it { expect(index.name).to eq 'idx_bnr_reps_rep_code' }
            it { expect(index.table).to eq table_schema.to_sym }
            it { expect(index.columns).to include(:rep_code) }
            it { expect(index.columns).to have(1).item }
            it { should_not be_composite }
          end

          context "with 'true' value" do
            before { @column = DataColumnSchema.new(:rep_code, index: true).in_table table_schema }
            it_behaves_like "rep code index"
            it { should_not be_clustered }
            it { should_not be_unique }
          end

          context "with 'false' value" do
            before { @column = DataColumnSchema.new(:rep_code, index: false).in_table table_schema }
            it { should be_nil }
          end

          context "with 'unique' attribute" do
            before { @column = DataColumnSchema.new(:rep_code, index: { unique: true }).in_table table_schema }
            it_behaves_like "rep code index"
            it { should_not be_clustered }
            it { should be_unique }
          end

          context "with 'clustered' attribute" do
            before { @column = DataColumnSchema.new(:rep_code, index: { clustered: true }).in_table table_schema }
            it_behaves_like "rep code index"
            it { should be_clustered }
            it { should be_unique }
          end
        end

        context "when the column schema does not define index" do
          before { @column = DataColumnSchema.new(:rep_code).in_table table_schema }
            it { should be_nil }
        end
      end


      describe '#has_unique_constraint?' do
        subject { @column.has_unique_constraint? }

        context "when the column schema defines unique constraint" do
          context "with 'true' value" do
            before { @column = DataColumnSchema.new(:rep_code, unique: true) }
            it { should be true }
          end

          context "with 'false' value" do
            before { @column = DataColumnSchema.new(:rep_code, unique: false) }
            it { should be false }
          end
        end

        context "when the column schema does not define unique constraint" do
          before { @column = DataColumnSchema.new(:rep_code) }
          it { should be false }
        end
      end


      describe '#unique_constraint' do
        subject(:constraint) { @column.unique_constraint }

        context "when the column schema defines unique constraint" do
          shared_examples_for "rep code unique constraint" do
            it { should be_a Gauge::DB::Constraints::UniqueConstraint }
            it { expect(constraint.name).to eq 'uc_bnr_reps_rep_code' }
            it { expect(constraint.table).to eq table_schema.to_sym }
            it { expect(constraint.columns).to include :rep_code }
            it { expect(constraint.columns).to have(1).item }
            it { should_not be_composite }
          end

          context "with 'true' value" do
            before { @column = DataColumnSchema.new(:rep_code, unique: true).in_table table_schema }
            it_behaves_like "rep code unique constraint"
          end

          context "with 'false' value" do
            before { @column = DataColumnSchema.new(:rep_code, unique: false).in_table table_schema }
            it { should be_nil }
          end
        end

        context "when the column schema does not define unique constraint" do
          before { @column = DataColumnSchema.new(:rep_code).in_table table_schema }
            it { should be_nil }
        end
      end


      describe '#has_foreign_key?' do
        subject { @column.has_foreign_key? }

        context "when the column schema defines a foreign key" do
          context "with default SQL schema" do
            before { @column = DataColumnSchema.new(:ref => :offices) }
            it { should be true }
          end

          context "with custom SQL schema combined with ref table name" do
            before { @column = DataColumnSchema.new(:ref => 'bnr.offices') }
            it { should be true }
          end

          context "with custom SQL schema defined using hash based option" do
            before { @column = DataColumnSchema.new(:ref => { table: :offices, sql_schema: :bnr }) }
            it { should be true }
          end

          context "with ref to custom data column" do
            before { @column = DataColumnSchema.new(:ref => { table: :offices, column: :office_code }) }
            it { should be true }
          end
        end

        context "when the column schema does not define a foreign key" do
          before { @column = DataColumnSchema.new(:rep_code) }
          it { should be false }
        end
      end


      describe '#foreign_key' do
        subject(:foreign_key) { @column.foreign_key }

        context "when the column schema defines a foreign key" do
          shared_examples_for "foreign key constraint" do
            it { should be_a Gauge::DB::Constraints::ForeignKeyConstraint }
            it { expect(foreign_key.table).to eq table_schema.to_sym }
            it { expect(foreign_key.columns).to have(1).item }
            it { expect(foreign_key.ref_columns).to have(1).column }
            it { should_not be_composite }
          end

          context "with default SQL schema" do
            before { @column = DataColumnSchema.new(:ref => :offices).in_table table_schema }

            it_behaves_like "foreign key constraint"
            it { expect(foreign_key.name).to eq 'fk_bnr_reps_dbo_offices_office_id' }
            it { expect(foreign_key.columns).to include :office_id }
            it { expect(foreign_key.ref_table).to be :dbo_offices }
            it { expect(foreign_key.ref_columns).to include :id }
          end

          context "with custom SQL schema combined with ref table name" do
            before { @column = DataColumnSchema.new(:ref => 'bnr.offices').in_table table_schema }

            it_behaves_like "foreign key constraint"
            it { expect(foreign_key.name).to eq 'fk_bnr_reps_bnr_offices_office_id' }
            it { expect(foreign_key.columns).to include :office_id }
            it { expect(foreign_key.ref_table).to be :bnr_offices }
            it { expect(foreign_key.ref_columns).to include :id }
          end

          context "with custom SQL schema defined using hash based option" do
            before do
              @column = DataColumnSchema.new(:ref => { table: :offices, schema: :bnr }).in_table table_schema
            end

            it_behaves_like "foreign key constraint"
            it { expect(foreign_key.name).to eq 'fk_bnr_reps_bnr_offices_office_id' }
            it { expect(foreign_key.columns).to include :office_id }
            it { expect(foreign_key.ref_table).to be :bnr_offices }
            it { expect(foreign_key.ref_columns).to include :id }
          end

          context "with ref to custom data column" do
            before do
              @column = DataColumnSchema.new(:office_code,
                :ref => { table: :offices, column: :office_code }).in_table table_schema
            end

            it_behaves_like "foreign key constraint"
            it { expect(foreign_key.name).to eq 'fk_bnr_reps_dbo_offices_office_code' }
            it { expect(foreign_key.columns).to include :office_code }
            it { expect(foreign_key.ref_table).to be :dbo_offices }
            it { expect(foreign_key.ref_columns).to include :office_code }
          end
        end

        context "when the column schema does not define a foreign key" do
          before { @column = DataColumnSchema.new(:rep_code) }
          it { should be_nil }
        end
      end


      describe '#in_table' do
        before { @table_schema = double('table_schema') }

        it "sets table name for the data column" do
          column.in_table @table_schema
          column.table.should == @table_schema
        end

        it "returns self (column schema instance)" do
          column.in_table(@table_schema).should be_equal(column)
        end
      end


      describe '#computed?' do
        subject { @column_schema.computed? }
        context "for regular columns" do
          before { @column_schema = DataColumnSchema.new(:rep_code, len: 10) }
          it { should be false }
        end

        context "for computed columns" do
          before { @column_schema = DataColumnSchema.new(:source_firm_code, computed: { function: :get_source_code }) }
          it { should be true }
        end
      end


      describe '#bool?' do
        before do
          @bool_columns = [
            DataColumnSchema.new(:active, type: :bool),
            DataColumnSchema.new(:is_active),
            DataColumnSchema.new(:has_participants),
            DataColumnSchema.new(:allow_delete)
          ]
          @other_columns = [
            DataColumnSchema.new(:code),
            DataColumnSchema.new(:created_at),
            DataColumnSchema.new(:is_active, type: :enum)
          ]
        end

        it "returns true for boolean data columns" do
          @bool_columns.each { |col| col.bool?.should be true }
        end

        it "returns false for all other column types" do
          @other_columns.each { |col| col.bool?.should be false }
        end
      end

  private

      def columns
        [
          [[:last_name, {}],                                        'nvarchar(255) null'],
          [[:rep_code, {len: 10}],                                  'nvarchar(10) null'],
          [[:description, {len: :max}],                             'nvarchar(max) null'],
          [[:total_amount, {type: :money}],                         'decimal(18,2) null'],
          [[:rate, {type: :percent, required: true}],               'decimal(18,4) not null'],
          [[:state_code, {type: :us_state}],                        'nchar(2) null'],
          [[:country, {type: :country, required: true}],            'nchar(2) not null'],
          [[:service_flag, {type: :char}],                          'nchar(1) null'],
          [[:account_id, {id: true}],                               'bigint not null'],
          [[:total_years, {type: :int, required: true}],            'int not null'],
          [[nil, {id: true}],                                       'bigint not null'],
          [[nil, {:ref => :primary_reps}],                          'bigint null'],
          [[:created_at, {}],                                       'datetime null'],
          [[:created_on, {required: true}],                         'date not null'],
          [[:snapshot, {type: :xml}],                               'xml null'],
          [[:photo, {type: :blob, required: true}],                 'varbinary(max) not null'],
          [[:hash_code, {type: :binary, len: 10, required: true}],  'binary(10) not null'],
          [[:is_active, {}],                                        'tinyint null'],
          [[:status, {type: :short, required: true}],               'smallint not null'],
          [[:risk_tolerance, {type: :enum, required: true}],        'tinyint not null'],
          [[:trade_guid, {type: :guid}],                            'uniqueidentifier null']
        ]
      end
    end
  end
end
