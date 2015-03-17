# Eithery Lab., 2015.
# Gauge::Validators::DatabaseValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe DatabaseValidator do
      let(:validator) { DatabaseValidator.new }
      let(:db_column) { double('db_column', :allow_null? => false, data_type: :bigint, default_value: nil,
          length: Schema::DataColumnSchema::DEFAULT_VARCHAR_LENGTH) }
      let(:dba) { double('dba', table_exists?: true, column_exists?: true, column: db_column) }
      let(:schema) do
        db_schema = Schema::DatabaseSchema.new(:test_db)
        tables = {}
        %w(master_accounts customers primary_reps).map do |table_name|
          tables[table_name.to_sym] = Schema::DataTableSchema.new(table_name.to_sym)
        end
        db_schema.stub(tables: tables)
        db_schema
      end

      it_behaves_like "any database object validator"
      it { should respond_to :do_check_all }


      describe '#check' do
        before do
          validator.stub(:info)
          DataTableValidator.any_instance.stub(:log)
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

        it "displays an error if no data tables defined in metadata" do
          empty_schema = Schema::DatabaseSchema.new(:test_db)
          empty_schema.stub(tables: {})
          validator.stub(:error)
          validator.check empty_schema, dba
          validator.errors.should include(/cannot found data tables metadata for (.*?)test_db(.*?) database/i)
        end
      end
    end
  end
end
