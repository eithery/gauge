# Eithery, 2020
# Help command
# frozen_string_literal: true

module Gauge
  class CLI < Thor
    def help(*)
      args.empty? ? with_greeting { super } : super
    end

    private

    def with_greeting
      puts AppInfo::GREETING + $/
      result = yield
      puts AppInfo::HELP_COMMAND
      result
    end
  end
end
