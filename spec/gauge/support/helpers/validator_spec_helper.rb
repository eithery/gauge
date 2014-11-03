# Eithery Lab., 2014.
# Class Gauge::Validators::ValidatorSpecHelper
# Provides the set of helper methods for Validator specs.
module Gauge
  module Validators
    module ValidatorSpecHelper
      def no_validation_errors_detected
        @errors.should_not_receive(:<<)
        validator.validate(@column_schema, @db_column)
        @errors.should be_empty
      end


      def should_append_error_message(error_message)
        @errors.should_receive(:<<).with(error_message)
        validator.validate(@column_schema, @db_column)
      end
    end
  end
end
