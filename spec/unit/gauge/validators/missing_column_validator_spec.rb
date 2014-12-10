# Eithery Lab., 2014.
# Gauge::Validators::MissingColumnValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe MissingColumnValidator do
      let(:validator) { MissingColumnValidator.new }
      let(:table_schema) { Schema::DataTableSchema.new(:accounts) }
      let(:schema) { Schema::DataColumnSchema.new(:account_number).in_table table_schema }
      let(:dba) { double('dba') }

      let(:sql_script) do
        "alter table dbo.accounts\n" +
        "add [account_number] nvarchar(256) null;\n" +
        "go"
      end

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        subject { validate }
        before do
          File.stub(:open)
          Dir.stub(:mkdir)
        end

        context "when data column exists in the table" do
          before { dba.stub(:column_exists?).and_return(true) }

          specify { no_validation_errors { |schema, dba| validate } }
          it { should be true }

          it "does not generate SQL scripts" do
            validator.should_not_receive(:save_sql)
            validate
          end
        end


        context "when missing data column" do
          before { dba.stub(:column_exists?).and_return(false) }

          it { should_append_error(/data column '(.*?)account_number(.*)' does (.*?)NOT(.*?) exist/i) }
          it { should be false }

          it "builds SQL script to create missing column" do
            generated_script = ""
            validator.stub(:save_sql) do |table, script_name, &block|
              generated_script = block.call
            end
            validate
            generated_script.should == sql_script
          end

          it "saves SQL script" do
            validator.should_receive(:save_sql).with(table_schema, 'add_account_number_column')
            validate
          end
        end        
      end

  private

      def validate
        validator.do_validate(schema, dba)
      end
    end
  end
end
