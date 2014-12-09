# Eithery Lab., 2014.
# Class Gauge::Formatters::ColoredConsoleFormatter
# Displays colored messages to console terminal.
require 'gauge'

module Gauge
  module Formatters
    class ColoredConsoleFormatter

      def log(message, options={})
        puts colorize(message, options[:severity])
      end

  private

      def colorize(message, severity)
        message.split(/<b>(.*?)<\/b>/).map.with_index do |str, index|
          index.odd? ? str.colorize(severity).bright : str.colorize(severity)
        end.join
      end
    end
  end
end
