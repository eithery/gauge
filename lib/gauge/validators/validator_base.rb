# Eithery Lab., 2014.
# Class Gauge::Validators::ValidatorBase
# Represents abstract validator to check a database structure.
require 'gauge'

module Gauge
  module Validators
    class ValidatorBase
      include ConsoleListener

  protected

      # Performs validation of the specified database object against predefined schema.
      def validate(db_schema, dba)
        if block_given?
          yield db_schema, dba if before_validate db_schema, dba
        else
          validators.each do |v|
            v.validate db_schema, dba
            errors.concat v.errors
          end
        end
      end


      # Validators called before the main validation cycle.
      def before_validators
        []
      end


      # Child validators.
      def validators
        []
      end


      # Validation errors.
      def errors
        @errors ||= []
      end

  private

      def before_validate(db_schema, dba)
        before_validators.each do |v|
          res = v.validate db_schema, dba
          errors.concat v.errors
          return false unless res
        end
        true
      end
    end
  end
end
