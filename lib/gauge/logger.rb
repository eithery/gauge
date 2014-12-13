# Eithery Lab., 2014.
# Module Gauge::Logger
# Provides logging functionality using the set of various formatters.

module Gauge
  module Logger
    class << self
      attr_accessor :formatters
    end

    @formatters = []


    def log(*args)
      Logger.formatters.each { |f| f.log *args }
    end


    def error(message)
      log message, severity: :error
    end


    def warning(message)
      log message, severity: :warning
    end


    def info(message)
      log message, severity: :info
    end


    def ok(message)
      log message, severity: :success
    end


    def self.configure(options={})
      formatters.clear
      formatters << (options[:colored] ? Formatters::ColoredConsoleFormatter.new : Formatters::ConsoleFormatter.new)
    end
  end
end
