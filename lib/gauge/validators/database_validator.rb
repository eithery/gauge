require 'gauge'

module Gauge
  module Validators
    class DatabaseValidator
      include ConsoleListener

      def check(database_name)
        info "#{database_name} found!"
      end
    end
  end
end
