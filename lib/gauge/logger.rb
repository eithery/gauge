# Eithery Lab., 2014.
# Class Gauge::Logger
# Provides logging functionality using the set of various formatters.

module Gauge
  module Logger
    def log(message, options={})
      formatters.each { |f| f.log message, options }
    end


    def with_log(message, options={})
      print "#{message} ...".color(:cyan)
      return unless block_given?

      errors = yield
      if errors.empty?
        puts "\r#{message} - ok".color(:green)
      else
        puts "\r#{message} - failed".color(:red).bright
        puts "Errors:".color(:red)
        errors.each { |error| puts "- #{error}".color(:red) }
        puts "Total #{errors.count} errors found.\n".color(:red)
      end
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
