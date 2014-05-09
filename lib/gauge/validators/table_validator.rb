require 'gauge'

module Gauge
  module Validators
    class TableValidator
      include ConsoleListener

      def check(table_name)
        info "#{table_name} is found!"
      end
    end
  end
end
