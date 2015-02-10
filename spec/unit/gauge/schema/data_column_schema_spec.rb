# Eithery Lab., 2014.
# Gauge::Schema::DataColumnSchema specs.
require 'spec_helper'

module Gauge
  module Schema
    describe DataColumnSchema do
      let(:column) { DataColumnSchema.new(:account_number, type: :string, required: true) }
      let(:ref_column) { DataColumnSchema.new(:ref => 'br.primary_reps') }
      subject { column }

      it { should respond_to :column_name }
      it { should respond_to :column_type, :data_type, :sql_type }
      it { should respond_to :table }
      it { should respond_to :length, :char_column? }
      it { should respond_to :allow_null?, :default_value, :sql_default_value }
      it { should respond_to :to_key }
      it { should respond_to :id? }
      it { should respond_to :in_table }
      it { should respond_to :computed? }
      it { should respond_to :bool? }
      it { should respond_to :sql_attributes }


      describe '#initialize' do
        it "raises an error for not supported column types" do
          expect { DataColumnSchema.new(:customers, type: :unknown) }
            .to raise_error(ArgumentError, /invalid column type/i)
        end
      end


      describe '#column_name' do
        context "when name is explicitly passed in constructor arguments" do
          specify { column.column_name.should == 'account_number' }
        end

        context "when no name passed in constructors arguments" do
          context "and column attributes contain the ref to another table" do
            before { @ref_column = DataColumnSchema.new(:ref => :risk_tolerance, schema: :ref) }

            it "concludes the column name based on the ref" do
              ref_column.column_name.should == 'primary_rep_id'
              @ref_column.column_name.should == 'risk_tolerance_id'
            end
          end

          context "and column is defined as id" do
            before { @id_column = DataColumnSchema.new(id: true) }

            it "interprets the column name as id" do
              @id_column.column_name.should == 'id'
            end
          end

          context "and no refs to another table defined" do
            before { @no_name_column = DataColumnSchema.new }
            specify do
              expect { @no_name_column.column_name }.to raise_error(/column name is not specified/)
            end
          end
        end
      end


      describe '#table' do
        context "when column schema is created by data table schema" do
          before do
            @table_schema = DataTableSchema.new(:customers, sql_schema: :ref)
            @table_schema.col :account_number
          end
          specify { @table_schema.columns.last.table.should == @table_schema }
        end

        context "when column schema is created explicitly" do
          before { @column = DataColumnSchema.new(:account_number) }
          specify { @column.table.should be_nil }
        end
      end


      describe '#column_type' do
        context "when type is explicitly passed in constructor arguments" do
          before { @country_column = DataColumnSchema.new(:customers, type: :country) }

          it "returns initialized column type converted to symbol" do
            column.column_type.should == :string
            @country_column.column_type.should == :country
          end
        end

        context "when no type attribute is defined" do
          context "and column attributes contain the ref to another table" do
            context "and no column length defined" do
              specify { ref_column.column_type.should == :id }
            end

            context "and column length is defined" do
              before { @ref_column = DataColumnSchema.new(:trade_type_code, len: 10, :ref => :trade_types) }
              specify { @ref_column.column_type.should == :string }
            end
          end

          context "and column is defined as surrogate id" do
            context "and no column length defined" do
              before { @id_column = DataColumnSchema.new(:master_account_id, id: true) }
              specify { @id_column.column_type.should == :id }
            end

            context "and column length is defined" do
              before { @id_column = DataColumnSchema.new(:batch_code, len: 10, id: true) }
              specify { @id_column.column_type.should == :string }
            end
          end

          context "and column name contains 'is', 'has', or 'allow' prefix" do
            before do
              @bool_columns = ['is_visible', 'has_accounts', 'allow_delete'].map do |col_name|
                DataColumnSchema.new(col_name)
              end
            end
            it "should be boolean" do
              @bool_columns.each { |col| col.column_type.should == :bool }
            end  
          end

          context "and column name contains 'date' or '_at' suffix" do
            before do
              @date_time_columns = ['startDate', 'created_at'].map do |col_name|
                DataColumnSchema.new(col_name)
              end
            end
            it "should be datetime" do
              @date_time_columns.each { |col| col.column_type.should == :datetime }
            end
          end

          context "and column name contains '_on' suffix" do
            before { @column = DataColumnSchema.new(:created_on) }
            specify { @column.column_type.should == :date }
          end

          context "and column name does not contain specific prefixes or suffixes" do
            before { @column = DataColumnSchema.new(:account_number) }
            specify { @column.column_type.should == :string }
          end
        end
      end


      describe '#data_type' do
        it "supports convertion from the specified column type" do
          [:id, :long].should be_converted_to(:bigint)
          [:int].should be_converted_to(:int)
          [:string].should be_converted_to(:nvarchar)
          [:char, :us_state, :country].should be_converted_to(:nchar)
          [:bool, :byte, :enum].should be_converted_to(:tinyint)
          [:datetime].should be_converted_to(:datetime)
          [:date].should be_converted_to(:date)
          [:money, :percent].should be_converted_to(:decimal)
          [:xml].should be_converted_to(:xml)
          [:blob].should be_converted_to(:varbinary)
          [:binary].should be_converted_to(:binary)
          [:guid].should be_converted_to(:uniqueidentifier)
        end

        context "when data column represents surrogate primary key" do
          before { @id_column = DataColumnSchema.new(id: true) }

          context "for regular data table" do
            before { @id_column.in_table DataTableSchema.new(:customers) }
            specify { @id_column.data_type.should == :bigint }
          end

          context "for reference data table containing metadata" do
            before { @id_column.in_table DataTableSchema.new(:customers, type: :metadata) }
            specify { @id_column.data_type.should == :tinyint }
          end
        end
      end


      describe '#sql_type' do
        context "for character types" do
          specify do
            DataColumnSchema.new(:account_number).sql_type.should == 'nvarchar(256)'
            DataColumnSchema.new(:rep_code, len: 10).sql_type.should == 'nvarchar(10)'
            DataColumnSchema.new(:service_flag, type: :char).sql_type.should == 'nchar(1)'
          end
        end

        context "for money type" do
          specify { DataColumnSchema.new(:total_amount, type: :money).sql_type.should == 'decimal(18,2)'}
        end

        context "for percent type" do
          specify { DataColumnSchema.new(:bank_rate, type: :percent).sql_type.should == 'decimal(18,4)' }
        end

        context "for blob type" do
          specify { DataColumnSchema.new(:image, type: :blob).sql_type.should == 'varbinary(max)' }
        end

        context "for binary type" do
          specify { DataColumnSchema.new(:hash_code, type: :binary, len: 10).sql_type.should == 'binary(10)' }
        end

        context "for other types" do
          specify { DataColumnSchema.new(:status, type: :enum).sql_type.should == 'tinyint' }
          specify { DataColumnSchema.new(id: true).sql_type.should == 'bigint' }
          specify { DataColumnSchema.new(:created_at).sql_type.should == 'datetime' }
          specify { DataColumnSchema.new(:country, type: :country).sql_type.should == 'nchar(2)' }
          specify { DataColumnSchema.new(:state_code, type: :us_state).sql_type.should == 'nchar(2)' }
          specify { DataColumnSchema.new(:is_active).sql_type.should == 'tinyint' }
          specify { DataColumnSchema.new(:snapshot, type: :xml).sql_type.should == 'xml' }
          specify { DataColumnSchema.new(:trageGuid, type: :guid).sql_type.should == 'uniqueidentifier' }
        end
      end


      describe '#char_column?' do
        context "when the column type is one of character types" do
          before do
            @char_columns = [:string, :char, :us_state, :country]
              .map { |t| DataColumnSchema.new(:col_name, type: t) }
          end
          specify { @char_columns.each { |col| col.should be_char_column }}
        end

        context "when the column type is not character" do
          before do
            @non_char_columns = [:id, :long, :datetime, :money, :enum]
              .map { |t| DataColumnSchema.new(:col_name, type: t)}
          end
          specify { @non_char_columns.each { |col| col.should_not be_char_column }}
        end
      end


      describe '#allow_null?' do
        subject { @column.allow_null? }

        context "when no identity or required attributes defined" do
          before { @column = DataColumnSchema.new(:account_number) }
          it { should be true }
        end

        context "when the column is defined as identity column" do
          before { @column = DataColumnSchema.new(id: true) }
          it { should be false }
        end

        context "when the column defined as business identity column" do
          before { @column = DataColumnSchema.new(business_id: true) }
          it { should be false }
        end

        context "when the column is defined as required" do
          before { @column = DataColumnSchema.new(required: true) }
          it { should be false }
        end
      end


      describe '#length' do
        subject { @column.length }

        context "when column length is defined in metadata" do
          context "as integer value" do
            before { @column = DataColumnSchema.new(:rep_code, len: 10) }
            it "equals to predefined length value" do
              @column.length.should == 10
            end
          end

          context "as maximum available value" do
            before { @column = DataColumnSchema.new(:description, len: :max) }
            it { should == :max }
          end
        end


        context "when no column length defined" do
          context "for string columns" do
            before { @column = DataColumnSchema.new(:last_name, type: :string) }
            it { should == DataColumnSchema::DEFAULT_VARCHAR_LENGTH }
          end

          context "for char columns" do
            before { @column = DataColumnSchema.new(:trade_type, type: :char) }
            it { should  == DataColumnSchema::DEFAULT_CHAR_LENGTH }
          end

          context "for country code columns" do
            before { @column = DataColumnSchema.new(:country_code, type: :country) }
            it { should == DataColumnSchema::DEFAULT_ISO_CODE_LENGTH }
          end

          context "for US state code columns" do
            before { @column = DataColumnSchema.new(:state_code, type: :us_state) }
            it { should == DataColumnSchema::DEFAULT_ISO_CODE_LENGTH }
          end

          context "for other column types" do
            before { @column = DataColumnSchema.new(:created, type: :datetime) }
            it { should be_nil }
          end
        end
      end


      describe '#default_value' do
        subject { @column_schema.default_value }

        context "when defined explicitly in column attributes" do
          context "for enumeration (integer) data columns" do
            before { @column_schema = DataColumnSchema.new(:account_status, required: true, default: 1) }
            it { should be 1 }
          end

          context "for boolean data columns" do
            before { @column_schema = DataColumnSchema.new(:is_active, required: true, default: true) }
            it { should be true }
          end

          context "as UID" do
            before { @column_schema = DataColumnSchema.new(:account_id, id: true, default: :uid) }
            it { should == DataColumnSchema::UID }
          end

          context "as SQL function without arguments" do
            before { @column_schema = DataColumnSchema.new(:modified_at, default: { function: :getdate }) }
            it { should == 'getdate()' }
          end
        end

        context "when it is not defined in column attributes" do
          context "for boolean required columns" do
            before { @column_schema = DataColumnSchema.new(:is_restricted, required: true) }
            it { should be false }
          end

          context "for other columns" do
            before { @column_schema = DataColumnSchema.new(:rep_code) }
            it { should be nil }
          end
        end
      end


      describe '#sql_default_value' do
        it "returns nil if no default value defined" do
          DataColumnSchema.new(:trade_id, :ref => :trades).sql_default_value.should be nil
        end

        it "returns quoted default value for character types" do
          DataColumnSchema.new(:rep_code, default: 'R001').sql_default_value.should == "'R001'"
          DataColumnSchema.new(:country, type: :country, default: 'US').sql_default_value.should == "'US'"
        end

        it "returns 0 and 1 respectively for boolean types" do
          DataColumnSchema.new(:is_active, default: true).sql_default_value.should == 1
          DataColumnSchema.new(:is_active, required: true).sql_default_value.should == 0
        end

        it "returns unchanged default value for other column types" do
          DataColumnSchema.new(:created_at, default: { function: :getdate }).sql_default_value.should == 'getdate()'
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


      describe '#to_key' do
        it "returns column name converted to symbol" do
          column.to_key.should == :account_number
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
          [[:last_name, {}],                                        'nvarchar(256) null'],
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
