# Eithery Lab., 2014.
# Gauge::Validators::MissingTableValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe MissingTableValidator do
      let(:validator) { MissingTableValidator.new }
      it_behaves_like "any database object validator"

      describe '#validate' do
        before do
          create_dba_stubs
          create_data_table_stubs
        end

        context "when data table exists in the database" do
          before { @dba.stub(:table_exists?).and_return(true) }

          specify { no_validation_errors_detected }
          specify "returns true" do
            validator.validate(@table_schema, @dba).should be true
          end
        end

        context "when missing data table" do
          before { @dba.stub(:table_exists?).and_return(false) }

          it { should_append_error_message(/.*\[dbo\]\.\[master_accounts\].* data table - .*missing/i) }
          specify "returns false" do
            validator.validate(@table_schema, @dba).should be false
          end
        end        
      end
    end
  end
end
