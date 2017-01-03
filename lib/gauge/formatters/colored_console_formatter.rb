# Eithery Lab., 2017
# Class Gauge::Formatters::ColoredConsoleFormatter
# Displays colored messages to console/terminal.

require 'gauge'
require_relative 'console_formatter'

module Gauge
  module Formatters
    class ColoredConsoleFormatter < ConsoleFormatter

      def log(message, kind: nil)
        puts colorize(message, kind)
      end


  private

      def colorize(message, kind)
        message.split(/<b>(.*?)<\/b>/).map.with_index do |str, index|
          index.odd? ? str.colorize(kind).bright : str.colorize(kind)
        end.join
      end
    end
  end
end
