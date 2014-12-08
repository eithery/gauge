# Eithery Lab., 2014.
# Class Gauge::Formatters::ColoredConsoleFormatter
# Displays colored messages to console terminal.
require 'gauge'

module Gauge
  module Formatters
    class ColoredConsoleFormatter

      def log(message, options={})
        puts message.colorize(options[:severity])
      end


      def with_log(message, options={}, &block)
        print "#{message} ...".color(:cyan)
        errors = block.call
        if errors.empty?
          puts "\r#{message} - ok".color(:green)
        else
          puts "\r#{message} - failed".color(:red).bright
          puts "Errors:".color(:red)
          errors.each { |error| puts "- #{error}".color(:red) }
          puts "Total #{errors.count} errors found.\n".color(:red)
        end
      end
    end
  end
end
