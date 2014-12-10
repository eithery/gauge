# Eithery Lab., 2014.
# Gauge::SQL::Builder specs.
require 'spec_helper'

module Gauge
  module SQL
    describe Builder do
      let(:sql_script) { "alter [dbo].[customer] alter column [customer_name] nvarchar(256) not null" }
      let(:table_schema) { Schema::DataTableSchema.new(:customers) }
      subject { Builder }

      it { should respond_to :save_sql }


      describe '.save_sql' do
        before { File.stub(:open) }

        it "creates SQL home folder if it does not exist" do
          File.stub(:exists? => false)
          Dir.should_receive(:mkdir).with(/\/sql/).exactly(3).times
          save_sql
        end

        it "creates tables folder of it does not exist" do
          File.stub(:exists?).and_return(true, false, false)
          Dir.should_receive(:mkdir).with(/\/sql\/tables/).exactly(2).times
          save_sql
        end

        it "creates the separate folder for the specified data table" do
          File.stub(:exists?).and_return(true, true, false)
          Dir.should_receive(:mkdir).with(/\/sql\/tables\/dbo.customers/).once
          save_sql
        end

        it "creates SQL script file with the specified name" do
          File.stub(:exists? => true)
          File.should_receive(:open).with(/alter_customer_name_column.sql/, 'w')
          save_sql
        end

        it "writes SQL script into the file" do
          file = double('script_file')
          File.stub(:exists? => true)
          File.stub(:open) do |arg, arg2, &block|
            block.call(file)
          end
          file.should_receive(:puts).with(sql_script)
          save_sql
        end
      end

  private
  
      def save_sql
        Builder.save_sql(table_schema, 'alter_customer_name_column', sql_script)
      end
    end
  end
end
