# Eithery Lab., 2014.
# Gauge::Validators::MissingColumnValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe MissingColumnValidator do
      let(:validator) { MissingColumnValidator.new }
      it_behaves_like "any database object validator"

      describe '#validate' do
        before do
          create_dba_stubs
          create_data_column_stubs
        end

        context "when data column exists in the table" do
          before { @dba.stub(:column_exists?).and_return(true) }

          specify { no_validation_errors_detected }
          specify "returns true" do
            validator.validate(@column_schema, @dba).should be true
          end
        end

        context "when missing data column" do
          before { @dba.stub(:column_exists?).and_return(false) }

          it { should_append_error_message(/missing '.*account_number.*' data column/i) }
          specify "returns false" do
            validator.validate(@column_schema, @dba).should be false
          end
        end        
      end
    end
  end
end
