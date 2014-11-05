# Eithery Lab., 2014.
# Class Gauge::Validators::ValidatorBase
# Represents abstract validator to check a database structure.
require 'gauge'

module Gauge
  module Validators
    class ValidatorBase
      include ConsoleListener

      def errors
        @errors ||= []
      end


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


  protected

      def before_validators
        []
      end


      def validators
        []
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
