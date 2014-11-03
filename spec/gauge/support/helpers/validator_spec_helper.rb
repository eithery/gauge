# Eithery Lab., 2014.
# Class Gauge::Validators::ValidatorSpecHelper
# Provides the set of helper methods for Validator specs.
module Gauge
  module Validators
    module ValidatorSpecHelper

      def create_data_column_stubs
        @errors = []
        validator.stub(:errors).and_return(@errors)
        @column_schema = double('column_schema', column_name: 'account_number')
        @db_column = double('db_column')
        @dba = double('dba', data_column: @db_column)
      end


      def no_validation_errors_detected
        @errors.should_not_receive(:<<)
        validator.validate(@column_schema, @db_column)
        @errors.should be_empty
      end


      def should_append_error_message(error_message)
        @errors.should_receive(:<<).with(error_message)
        validator.validate(@column_schema, @db_column)
      end


      shared_examples_for "any database object validator" do
        subject { validator }
        it { should respond_to :validate }
      end
    end
  end
end
