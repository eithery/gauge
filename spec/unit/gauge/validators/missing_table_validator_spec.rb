# Eithery Lab., 2014.
# Gauge::Validators::MissingTableValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe MissingTableValidator do
      let(:validator) { MissingTableValidator.new }
      let(:schema) { @table_schema }
      let(:dba) { double('dba') }

      it_behaves_like "any database object validator"
      it { should respond_to :validate }


      describe '#validate' do
        before do
          @table_schema = Schema::DataTableSchema.new(:master_accounts)
        end

        context "when data table exists in the database" do
          before { dba.stub(:table_exists?).and_return(true) }

          specify { no_validation_errors { |schema, dba| validator.validate(schema, dba) } }
          specify { validator.validate(schema, dba).should be true }
        end

        context "when missing data table" do
          before { dba.stub(:table_exists?).and_return(false) }

          it { should_append_error(/'(.*)dbo\.master_accounts(.*)'(.*) data table \- (.*)missing/i) }
          specify { validator.validate(schema, dba).should be false }
        end
      end
    end
  end
end
