# Eithery, 2020
# Global options for CLI application
# frozen_string_literal: true

module Gauge
  class GlobalOptions
    def initialize(options)
      @options = options
    end

    def version?
      @options[:v]
    end

    def help?
      @options[:help]
    end

    def colored?
      @options[:colored]
    end
  end
end
