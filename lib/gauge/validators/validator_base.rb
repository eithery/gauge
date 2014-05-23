require 'gauge'

module Gauge
  module Validators
    class ValidatorBase
      include ConsoleListener

  protected

      def before_validate(db_schema, dba)
        before_validators.each do |v|
          res = v.validate db_schema, dba
          errors.concat v.errors
          return false unless res
        end
        true
      end


      def validate(db_schema, dba)
        validators.each do |v|
          v.validate db_schema, dba
          errors.concat v.errors
        end
      end


      def before_validators
        []
      end


      def validators
        []
      end


      def errors
        @errors ||= []
      end
    end
  end
end
