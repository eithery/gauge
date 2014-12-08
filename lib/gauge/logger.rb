# Eithery Lab., 2014.
# Class Gauge::Logger
# Provides logging functionality using the set of various formatters.

module Gauge
  module Logger

    def log(*args)
      formatters.each { |f| f.log *args }
    end


    def with_log(*args, &block)
      formatters.each { |f| f.with_log *args, &block }
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

  private

    def formatters
      [Formatters::ColoredConsoleFormatter.new]
    end
  end
end
