require 'gauge'

module Gauge
  module Validators
    class ValidatorBase
      include ConsoleListener

  protected

      def validate(db_schema, dba)
        validators.each do |v|
          v.validate db_schema, dba
          errors.concat v.errors
        end
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
