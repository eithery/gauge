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
        message.colorize severity
#        parts = message.split("'")
#        parts.each_with_index do |str, index|
#          parts[index] = parts[index].colorize(severity) if index % 2 == 0
#          parts[index] = "'".colorize(severity) + parts[index].colorize(severity).bright + "'".colorize(severity) if index % 2 == 1
#        end
#        result = parts.join
#        result.sub(/(- ok)/, '\1'.bright)
#          .sub(/(- failed)/, '\1'.bright)
        p message.scan(/(.*?)<b>(.*?)<\/b>(.*?)/)
      end
    end
  end
end
