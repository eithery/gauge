require 'gauge'

module Gauge
  module Validators
    class ValidatorBase
      include ConsoleListener

  protected
      # Child validators collection.
      def validators
        []
      end
    end
  end
end
