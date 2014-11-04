# Eithery Lab., 2014.
# Class Gauge::Validators::ValidatorSpecHelper
# Provides the set of helper methods for Validator specs.
module Gauge
  module Validators
    module ValidatorSpecHelper

      def create_dba_stubs
        create_data_column_stubs
        @dba = double('dba', data_column: @db_column, column_exists?: true)
      end


      def create_data_column_stubs
        @column_schema = double('column_schema', column_name: 'account_number')
        @db_column = double('db_column')
      end


      def stub_column_schema_nullability(nullability)
        allow_null = nullability == :null
        @column_schema.stub(:allow_null?).and_return(allow_null)
      end


      def stub_db_column_nullability(nullability)
        allow_null = nullability == :null
        @db_column.stub(:[]).with(:allow_null).and_return(allow_null)
      end


      def stub_column_schema_type(column_data_type)
        @column_schema.stub(:data_type).and_return(column_data_type)
      end


      def stub_db_column_type(column_data_type)
        @db_column.stub(:[]).with(:db_type).and_return(column_data_type)
      end


      def stub_validator(validator_class)
        validator = validator_class.new
        validator_class.stub(:new).and_return(validator)
        validator
      end


      def no_validation_errors_detected
        validator.errors.should_not_receive(:<<)
        expect { validator.validate(@column_schema, @db_column) }.not_to change { validator.errors.count }
        validator.validate(@column_schema, @db_column)
        validator.errors.should be_empty
      end


      def should_append_error_message(error_message)
        validator.errors.should_receive(:<<).with(error_message)
        validator.validate(@column_schema, @db_column)
      end


      shared_examples_for "any database object validator" do
        subject { validator }
        it { should respond_to :validate }
        it { should respond_to :errors }
      end
    end
  end
end
