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
        parts = message.split(/<b>(.*?)<\/b>/)
        parts.each_with_index do |str, index|
          parts[index] = parts[index].colorize(severity)
          parts[index] = parts[index].bright if index % 2 == 1
        end
        parts.join
      end
    end
  end
end
