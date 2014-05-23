require 'gauge'

module Gauge
  module Validators
    class ValidatorBase
      include ConsoleListener

  protected

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


      def before_validators
        []
      end


      def validators
        []
      end


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
