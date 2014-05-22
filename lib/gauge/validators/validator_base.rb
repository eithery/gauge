require 'gauge'

module Gauge
  module Validators
    class ValidatorBase
      include ConsoleListener

  protected

      def validate(db_schema, dba)
        validators.each { |v| v.validate db_schema, dba }
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
