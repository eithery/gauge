# Eithery Lab., 2014.
# Class Gauge::Validators::ValidatorSpecHelper
# Provides the set of helper methods for Validator specs.
module Gauge
  module Validators
    module ValidatorSpecHelper

      def stub_validator(validator_class)
        validator = validator_class.new
        validator_class.stub(:new).and_return(validator)
        validator
      end


      def stub_db_adapter
        DB::Connection.stub(:server).and_return('local\SQL2012')
        DB::Connection.stub(:user).and_return('admin')
        DB::Connection.stub(:password).and_return('secret')
        Sequel::TinyTDS::Database.any_instance.stub(:test_connection)
      end


      def should_append_error(error_message)
        validator.errors.should_receive(:<<).with(error_message)
        validator.do_validate(schema, dba)
      end


      def no_validation_errors
        expect { yield(schema, dba) }.not_to change { validator.errors.count }

        validator.errors.should_not_receive(:<<)
        yield schema, dba
        validator.errors.should be_empty
      end


      shared_examples_for "any database object validator" do
        subject { validator }

        it { should respond_to :check }
        it { should respond_to :errors }
        it { should respond_to :build_sql }
        it { should respond_to :build_alter_column_sql }

        specify { validator.class.should respond_to :check_all }
        specify { validator.class.should respond_to :check_before }
        specify { validator.class.should respond_to :check }
        specify { validator.class.should respond_to :validate }

        specify { validator.errors.should_not be_nil }
        specify { validator.errors.should be_empty }
      end
    end
  end
end
