# Eithery Lab., 2014.
# Gauge::Validators::DatabaseValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DatabaseValidator do
      let(:validator) { DatabaseValidator.new }

      it_behaves_like "any database object validator"

      it { should respond_to :check_all }

      describe '#check' do
        before do
          create_dba_stubs
          @table_schema = double('table_schema')
          @db_schema = double('db_schema', tables: [@table_schema] * 3)
        end

        it "performs validation check for the database" do
         validator.should_receive(:check).with(@db_schema, @dba)
         validator.check @db_schema, @dba
        end

        it "creates validator to check data tables" do
          stub_table_validator = double('table_validator', check: true, errors: [])
          DataTableValidator.should_receive(:new).once.and_return(stub_table_validator)
          validator.check @db_schema, @dba
        end

        it "performs validation check for each data table in the database" do
          stub_validator(DataTableValidator).should_receive(:check)
            .with(@table_schema, @dba).exactly(3).times
          validator.check @db_schema, @dba
        end
      end
    end
  end
end
