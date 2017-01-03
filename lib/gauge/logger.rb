# Eithery Lab., 2017
# Module Gauge::Logger
# Provides logging functionality using the set of registered formatters.

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
      log message, kind: :error
    end


    def warning(message)
      log message, kind: :warning
    end


    def info(message)
      log message, kind: :info
    end


    def ok(message)
      log message, kind: :success
    end


    def self.configure(colored: false)
      formatters.clear
      formatters << (colored ? Formatters::ColoredConsoleFormatter.new : Formatters::ConsoleFormatter.new)
    end
  end
end
