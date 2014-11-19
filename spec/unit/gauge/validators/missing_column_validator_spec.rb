# Eithery Lab., 2014.
# Gauge::Validators::MissingColumnValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe MissingColumnValidator do
      let(:validator) { MissingColumnValidator.new }
      let(:schema) { Schema::DataColumnSchema.new(:account_number) }
      let(:dba) { double('dba') }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        context "when data column exists in the table" do
          before { dba.stub(:column_exists?).and_return(true) }

          specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) } }
          specify { validator.do_validate(schema, dba).should be true }
        end


        context "when missing data column" do
          before { dba.stub(:column_exists?).and_return(false) }

          it { should_append_error(/missing '(.*)account_number(.*)' data column/i) }
          specify { validator.do_validate(schema, dba).should be false }
        end        
      end
    end
  end
end
