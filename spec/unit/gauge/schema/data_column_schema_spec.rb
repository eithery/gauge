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
      it { should respond_to :column_type, :data_type }
      it { should respond_to :table_name }
      it { should respond_to :length, :char_column? }
      it { should respond_to :allow_null?, :default_value }
      it { should respond_to :to_key }
      it { should respond_to :id? }
      it { should respond_to :in_table }


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

          context "and no refs to another table defined" do
            before { @no_name_column = DataColumnSchema.new }
            specify do
              expect { @no_name_column.column_name }.to raise_error(/column name is not specified/)
            end
          end
        end
      end


      describe '#table_name' do
        context "when column schema is created by data table schema" do
          before do
            @table_schema = DataTableSchema.new(:customers)
            @table_schema.col :account_number
          end
          specify { @table_schema.columns.last.table_name.should == 'customers' }
        end

        context "when column schema is created explicitly" do
          before { @column = DataColumnSchema.new(:account_number) }
          specify { @column.table_name.should be_empty }
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
            specify { ref_column.column_type.should == :id }
          end

          context "and column is defined as surrogate id" do
            before { @id_column = DataColumnSchema.new(:master_account_id, id: true) }
            specify { @id_column.column_type.should == :id }
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
          context "for string type columns" do
            before do
              @string_column = DataColumnSchema.new(:last_name, type: :string)
              @char_column = DataColumnSchema.new(:trade_type, type: :char)
            end

            it "equals to default nvarchar column type value" do
              @string_column.length.should == DataColumnSchema::DEFAULT_VARCHAR_LENGTH
              @char_column.length.should == DataColumnSchema::DEFAULT_VARCHAR_LENGTH
            end
          end

          context "for non string column types" do
            before { @column = DataColumnSchema.new(:created, type: :datetime) }
            it { should be_nil }
          end

          context "for country and US state types" do
            before do
              @country_column = DataColumnSchema.new(:country_code, type: :country)
              @us_state_column = DataColumnSchema.new(:state_code, type: :us_state)
            end

            it "equals to default value of ISO state/country code" do
              @country_column.length.should == DataColumnSchema::DEFAULT_ISO_CODE_LENGTH
              @us_state_column.length.should == DataColumnSchema::DEFAULT_ISO_CODE_LENGTH
            end
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
        it "sets table name for the data column" do
          column.in_table 'customers'
          column.table_name.should == 'customers'
        end
      end
    end
  end
end
