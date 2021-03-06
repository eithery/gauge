# Eithery Lab, 2017
# Gauge::Validators::DatabaseValidator specs

require 'spec_helper'

module Gauge
  module Validators
    describe DatabaseValidator do
      let(:validator) { DatabaseValidator.new }
      let(:db_column) { double('db_column', allow_null?: false, data_type: :bigint, default_value: nil,
          length: Schema::DataColumnSchema::DEFAULT_VARCHAR_LENGTH) }
      let(:dba) { double('dba', table_exists?: true, column_exists?: true, column: db_column) }
      let(:schema) do
        schema = double('schema')
        tables = {}
        %w(master_accounts customers primary_reps).map do |table_name|
          tables[table_name.to_sym] = Schema::DataTableSchema.new(table_name.to_sym)
        end
        schema.stub(tables: tables)
        schema
      end

      it_behaves_like "any database object validator"
      it { should respond_to :check_all_data_tables, :check_all_data_views }


      describe '#check' do
        before do
          validator.stub(:info)
          DataTableValidator.any_instance.stub(:log)
        end

        it "creates a validator to check all data tables" do
          table_validator = double('table_validator', check: true, errors: [])
          DataTableValidator.should_receive(:new).once.and_return(table_validator)
          validator.check schema, dba
        end

        it "creates a validator to check all data views" do
          table_validator = double('table_validator', check: true, errors: [])
          DataTableValidator.stub(:new).and_return(table_validator)

          view_validator = double('view_validator', check: true, errors: [])
          expect(DataViewValidator).to receive(:new).once.and_return(view_validator)
          validator.check schema, dba
        end

        it "performs validation check for each data table in the database" do
          stub_validator(DataTableValidator).should_receive(:check)
            .with(instance_of(Schema::DataTableSchema), dba, anything).exactly(3).times
          validator.check schema, dba
        end

        it "performs validation check for each data view in the database"

        it "displays an error if no data tables defined in metadata" do
          empty_schema = Schema::DatabaseSchema.new(:test_db)
          empty_schema.stub(tables: {})
          validator.stub(:error)
          validator.check empty_schema, dba
          expect(validator.errors).to include(/cannot found data tables metadata for (.*?)test_db(.*?) database/i)
        end

        it "deletes all SQL migration script files generated during previous runs" do
          schema.stub(tables: {})
          validator.stub(:error)
          expect(SQL::Builder.any_instance).to receive(:cleanup).with(schema)
          validator.check schema, dba
        end
      end
    end
  end
end
