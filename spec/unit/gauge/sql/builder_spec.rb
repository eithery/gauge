# Eithery Lab., 2014.
# Gauge::SQL::Builder specs.
require 'spec_helper'

module Gauge
  module SQL
    describe Builder do
      let(:builder) { Builder.new }
      let(:sql_script) { "alter [dbo].[customer] alter column [customer_name] nvarchar(256) not null" }
      let(:database_schema) { double('database', sql_name: 'books_n_records') }
      let(:table_schema) { Schema::DataTableSchema.new(:customers, sql_schema: :bnr, database: database_schema) }
      let(:column_schema) { Schema::DataColumnSchema.new(:account_number).in_table table_schema }

      subject { builder }

      it { should respond_to :build_sql }
      it { should respond_to :alter_table, :add_column }


      describe '#build_sql' do
        before { File.stub(:open) }

        it "creates SQL home folder if it does not exist" do
          File.stub(:exists? => false)
          Dir.should_receive(:mkdir).with(/\/sql/).exactly(4).times
          build_sql
        end

        it "creates database folder if it does not exist" do
          File.stub(:exists?).and_return(true, false, false, false)
          Dir.should_receive(:mkdir).with(/\/sql\/books_n_records/).exactly(3).times
          build_sql
        end

        it "creates tables folder if it does not exist" do
          File.stub(:exists?).and_return(true, true, false, false)
          Dir.should_receive(:mkdir).with(/\/sql\/books_n_records\/tables/).exactly(2).times
          build_sql
        end

        it "creates the separate folder for the specified data table" do
          File.stub(:exists?).and_return(true, true, true, false)
          Dir.should_receive(:mkdir).with(/\/sql\/books_n_records\/tables\/bnr.customers/).once
          build_sql
        end

        it "creates SQL script file with the specified name" do
          File.stub(:exists? => true)
          File.should_receive(:open).with(/alter_customer_name_column.sql/, 'w')
          build_sql
        end

        it "writes SQL script into the file" do
          file = double('script_file')
          File.stub(:exists? => true)
          File.stub(:open) do |arg, arg2, &block|
            block.call(file)
          end
          file.should_receive(:puts).with(sql_script)
          build_sql
        end
      end


      describe '#alter_table' do
        it "creates ALTER TABLE SQL clause" do
          builder.alter_table(table_schema).should == "alter table [bnr].[customers]"
        end
      end


      describe '#add_column' do
        it "creates SQL statement to add the new data column" do
          builder.add_column(column_schema).should == "add [account_number] nvarchar(256) null;"
        end
      end

  private
  
      def build_sql
        builder.build_sql(:add_column, column_schema) {}
      end
    end
  end
end
