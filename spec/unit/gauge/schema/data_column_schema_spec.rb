# Eithery Lab., 2014.
# Gauge::Schema::DataColumnSchema specs.
require 'spec_helper'

module Gauge
  module Schema
    describe DataColumnSchema do
      let(:column) { DataColumnSchema.new(:account_number, type: :string, required: true) }
      let(:ref_column) { DataColumnSchema.new(nil, ref: 'br.primary_reps') }
      subject { column }

      it { should respond_to :column_name }
      it { should respond_to :column_type, :data_type }
      it { should respond_to :table_name }
      it { should respond_to :allow_null? }
      it { should respond_to :to_key }
      it { should respond_to :id? }


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
            it "concludes the column name based on the ref" do
              ref_column.column_name.should == 'primary_rep_id'
            end
          end

          context "and no refs to another table defined" do
            before { @no_name_column = DataColumnSchema.new(nil) }
            specify do
              expect { @no_name_column.column_name }.to raise_error(/column name is not specified/)
            end
          end
        end
      end


      describe '#table_name' do
        context "when table name is explicitly passed in constructor arguments" do
          before { @column = DataColumnSchema.new(:account_number, table: :master_accounts) }
          specify { @column.table_name.should == 'master_accounts' }
        end

        context "when no table names passed in constructor arguments" do
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


      describe '#allow_null?' do
        subject { @column.allow_null? }

        context "when no identity or required attributes defined" do
          before { @column = DataColumnSchema.new(:account_number) }
          it { should be true }
        end

        context "when the column is defined as identity column" do
          before { @column = DataColumnSchema.new(nil, id: true) }
          it { should be false }
        end

        context "when the column defined as business identity column" do
          before { @column = DataColumnSchema.new(nil, business_id: true) }
          it { should be false }
        end

        context "when the column is defined as required" do
          before { @column = DataColumnSchema.new(nil, required: true) }
          it { should be false }
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
    end
  end
end
