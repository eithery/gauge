# Eithery, 2020
# Help command
# frozen_string_literal: true

module Gauge
  class CLI
    def help(*)
      args.empty? ? with_greeting { super } : super
    end

    private

    def with_greeting
      puts GREETING + $/
      result = yield
      puts HELP_COMMAND_MSG
      result
    end

    HELP_COMMAND_MSG = "Run 'gauge help <COMMAND>' for more information about a specific command"
    GREETING = <<~EOS
      Gauge. Database toolbox for MS SQL Server. Version #{VERSION}

      usage: gauge [<global options>] <COMMAND> [<args>] [<command options>]
    EOS
  end
end
