# Eithery, 2020
# Application greeting and help messages
# frozen_string_literal: true

module Gauge
  module AppInfo
    GREETING = <<~EOS
      Gauge. Database toolbox for MS SQL Server. Version #{VERSION}

      usage: gauge [<global options>] <COMMAND> [<args>] [<command options>]
    EOS
    HELP_COMMAND = "Run 'gauge help <COMMAND>' for more information about a specific command"

    def self.version
      "Gauge version #{VERSION}"
    end
  end
end
