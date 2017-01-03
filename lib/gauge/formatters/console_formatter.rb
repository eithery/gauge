# Eithery Lab., 2017
# Class Gauge::Formatters::ConsoleFormatter
# Displays messages to console/terminal.

require 'gauge'

module Gauge
  module Formatters
    class ConsoleFormatter

      def log(message, kind: nil)
        puts strip_tags(message)
      end


      def error(message)
        log message, kind: :error
      end


      def warning(message)
        log message, kind: :warning
      end


      def success(message)
        log message, kind: :success
      end


      def info(message)
        log message, kind: :info
      end


  private

      def strip_tags(message)
        message.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, '')
      end
    end
  end
end
