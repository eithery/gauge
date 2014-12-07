# Eithery Lab., 2014.
# Gauge::Validators::DatabaseValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DatabaseValidator do
      let(:validator) { DatabaseValidator.new }
      let(:db_column) do
        db_column = double('db_column')
        db_column.stub(:allow_null?).and_return(false)
        db_column.stub(:data_type).and_return(:bigint)
        db_column.stub(:length).and_return(Schema::DataColumnSchema::DEFAULT_VARCHAR_LENGTH)
        db_column.stub(:default_value).and_return(nil)
        db_column
      end
      let(:dba) { double('dba', table_exists?: true, column_exists?: true, column: db_column) }
      let(:schema) do
        db_schema = Schema::DatabaseSchema.new(:test_db)
        tables = {}
        %w(master_accounts customers primary_reps).map do |table_name|
          tables[table_name.to_sym] = Schema::DataTableSchema.new(table_name.to_sym)
        end
        db_schema.stub(:tables).and_return tables
        db_schema
      end

      it_behaves_like "any database object validator"
      it { should respond_to :do_check_all }


      describe '#check' do
        before do
          validator.stub(:info)
          DataTableValidator.any_instance.stub(:log) do |message, &block|
            block.call
          end
        end

        it "creates validator to check data tables" do
          stub_table_validator = double('table_validator', check: true, errors: [])
          DataTableValidator.should_receive(:new).once.and_return(stub_table_validator)
          validator.check schema, dba
        end

        it "performs validation check for each data table in the database" do
          stub_validator(DataTableValidator).should_receive(:check)
            .with(instance_of(Schema::DataTableSchema), dba).exactly(3).times
          validator.check schema, dba
        end

        it "displays database validation header message" do
          allow(validator).to receive(:info).and_call_original
          expect { validator.check(schema, dba) }.to output(/inspecting 'test_db' database/i).to_stdout
        end
      end
    end
  end
end
