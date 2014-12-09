# Eithery Lab., 2014.
# Class Gauge::Formatters::ConsoleFormatter
# Displays messages to console terminal.
require 'gauge'

module Gauge
  module Formatters
    class ConsoleFormatter

      def log(message, options={})
        puts strip_tags(message)
      end

  private

      def strip_tags(message)
        message.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, '')
      end
    end
  end
end
