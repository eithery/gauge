# Eithery Lab., 2014.
# Gauge::Validators::DatabaseValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DatabaseValidator do
      let(:validator) { DatabaseValidator.new }
      let(:dba) { double('dba') }
      let(:schema) do
        db_schema = Schema::DatabaseSchema.new(:test_db)
        tables = %w(master_accounts customers primary_reps).map do |table_name|
          Schema::DataTableSchema.new(table_name.to_sym)
        end
        db_schema.stub(:tables).and_return tables
        db_schema
      end

      it_behaves_like "any database object validator"
      it { should respond_to :check_all }


      describe '#check' do
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
      end
    end
  end
end
