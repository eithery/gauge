# Eithery Lab., 2017
# Class Gauge::Validators::ValidatorSpecHelper
# Provides the set of helper methods for Validator specs.

module Gauge
  module Validators
    module ValidatorSpecHelper
      def stub_db_adapter
        allow(DB::Connection).to receive(:server) { 'local\SQLDEV' }
        allow(DB::Connection).to receive(:user) { 'admin' }
        allow(DB::Connection).to receive(:password) { 'secret' }
        Sequel::TinyTDS::Database.any_instance.stub(:test_connection)
      end


      def stub_validator(validator_class)
        validator = validator_class.new
        validator_class.stub(:new).and_return(validator)
        validator
      end


      def stub_file_system
        Dir.stub(:mkdir)
        File.stub(:open)
      end


      def should_append_error(error_message)
        validator.errors.as_null_object.should_receive(:<<).with(error_message)
        validator.do_validate(schema, dba, sql)
      end


      def yields_error(error, options={})
        get_message_method = method("#{error.to_s.downcase}_message")
        should_append_error get_message_method.call(options)
      end


      def no_validation_errors
        expect { yield(schema, dba) }.not_to change { validator.errors.count }

        validator.errors.should_not_receive(:<<)
        yield schema, dba
        validator.errors.should be_empty
      end


      def should_not_yield_errors
        no_validation_errors { |schema, dba, sql| validator.do_validate(schema, dba, sql) }
      end


      def displayed_names_of(columns)
        columns.map { |col| "\\'(.*?)#{col}(.*?)\\'" }.join(', ')
      end
    end
  end
end
