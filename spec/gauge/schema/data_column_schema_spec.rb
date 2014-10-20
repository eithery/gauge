# Eithery Lab., 2014.
# Gauge::Schema::DataColumnSchema specs.
require 'spec_helper'

module Gauge
  module Schema
    describe DataColumnSchema do
      let(:table_name) { 'my_sample_table' }
      let(:column) { DataColumnSchema.new(table_name, name: 'account_number', type: :string, required: true) }
      let(:ref_column) { DataColumnSchema.new(table_name, ref: 'br.primary_reps') }
      subject { column }

      it { should respond_to :table_name, :column_name, :column_type, :data_type }
      it { should respond_to :allow_null? }
      it { should respond_to :to_key }

      describe '#table_name' do
        it "returns the table name passed in the initializer" do
          column.table_name.should == table_name
        end
      end

      describe '#column_name' do
        context "when name is explicitly passed in constructor arguments" do
          subject { column.column_name }
          it { should == 'account_number' }
        end

        context "when no name passed in constructors arguments" do
          context "and column attributes contain the ref to another table" do
            it "concludes the column name based on the ref" do
              ref_column.column_name.should == 'primary_rep_id'
            end
          end

          context "and no refs to another table defined" do
            before { @no_name_column = DataColumnSchema.new(table_name) }
            it "should raise the error" do
              expect { @no_name_column.column_name }.to raise_error('Data column name is not specified.')
            end
          end
        end
      end


      describe '#column_type' do
        subject { @column.column_type }
        context "when type is explicitly passed in constructor arguments" do
          before { @country_column = DataColumnSchema.new(table_name, type: :country) }

          it "returns initialized column type converted to symbol" do
            column.column_type.should == :string
            @country_column.column_type.should == :country
          end
        end

        context "when no type attribute is defined" do
          context "and column attributes contain the ref to another table" do
            subject { ref_column.column_type }
            it { should == :id }
          end

          context "and column name contains 'is', 'has', or 'allow' prefix" do
            before do
              @bool_columns = ['is_visible', 'has_accounts', 'allow_delete'].map do |col_name|
                DataColumnSchema.new(table_name, name: col_name)
              end
            end
            it "should be boolean" do
              @bool_columns.each { |col| col.column_type.should == :bool }
            end  
          end

          context "and column name contains 'date' or '_at' suffix" do
            before do
              @date_time_columns = ['startDate', 'created_at'].map do |col_name|
                DataColumnSchema.new(table_name, name: col_name)
              end
            end
            it "should be datetime" do
              @date_time_columns.each { |col| col.column_type.should == :datetime }
            end
          end

          context "and column name contains '_on' suffix" do
            before { @column = DataColumnSchema.new(table_name, name: 'created_on') }
            it { should == :date }
          end

          context "and column name does not contain specific prefixes or suffixes" do
            before { @column = DataColumnSchema.new(table_name, name: 'account_number') }
            it { should == :string }
          end
        end
      end


      describe '#data_type' do
      end


      describe '#allow_null?' do
      end


      describe '#to_key' do
      end
    end
  end
end
