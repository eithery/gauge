# Eithery Lab., 2015.
# Gauge::Validators::MissingTableValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe MissingTableValidator do
      let(:validator) { MissingTableValidator.new }
      let(:schema) { @table_schema }
      let(:dba) { double('dba') }
      let(:sql) { double('sql') }

      it_behaves_like "any database object validator"
      it { should respond_to :do_validate }


      describe '#validate' do
        before do
          @table_schema = Schema::DataTableSchema.new(:master_accounts)
        end

        context "when data table exists in the database" do
          before { dba.stub(:table_exists?).and_return(true) }

          it { should_not_yield_errors }
          specify { validator.do_validate(schema, dba, sql).should be true }
        end

        context "when missing data table" do
          before { dba.stub(:table_exists?).and_return(false) }

          it { should_append_error(/data table '(.*?)dbo\.master_accounts(.*?)' does not exist/i) }
          specify { validator.do_validate(schema, dba, sql).should be false }
        end
      end
    end
  end
end
