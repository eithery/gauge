# Eithery Lab., 2014.
# Class Gauge::Formatters::ColoredConsoleFormatter
# Displays colored messages to console terminal.
require 'gauge'

module Gauge
  module Formatters
    class ColoredConsoleFormatter

      def log(message, options={})
        puts message.colorize_as(options[:severity])
      end
    end
  end
end
