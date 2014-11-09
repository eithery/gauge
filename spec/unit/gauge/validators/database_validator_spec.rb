# Eithery Lab., 2014.
# Gauge::Validators::DatabaseValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DatabaseValidator do
      let(:validator) { DatabaseValidator.new }
      let(:database_schema) do
        double('database_schema', database_name: :accounts_profile, sql_name: 'accounts_db_name',
          tables: {
            accounts: double('accounts', sql_schema: 'dbo'),
            reps: double('reps', sql_schema: 'ref'),
            customers: double('customers', sql_schema: 'dbo')
          })
      end

      it_behaves_like "any database object validator"
      it { should respond_to :check }


      describe '#check' do
        before do
          stub_db_adapter
          validator.stub(:info)
        end

        it "displays database validation header message" do
          DB::Adapter.stub(:session)
          allow(validator).to receive(:info).and_call_original
          expect { validator.check(database_schema) }.to output(/inspecting 'accounts_profile' database/i).to_stdout
        end

        it "runs within data adapter session" do
          DB::Adapter.should_receive(:session).with('accounts_db_name')
          validator.check database_schema
        end

        it "performs validation check for each data table in the database" do
          stub_validator(DataTableValidator).should_receive(:validate)
            .with(anything, instance_of(Sequel::TinyTDS::Database)).exactly(3).times
          validator.check database_schema
        end
      end
    end
  end
end
