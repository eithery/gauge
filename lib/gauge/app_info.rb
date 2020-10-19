# Eithery, 2020
# Application info
# frozen_string_literal: true

module Gauge
  module AppInfo
    VERSION = '1.0.0'
    HEADER = <<~EOS
      Gauge. Database toolbox for MS SQL Server. Version #{VERSION}

      usage: gauge [<global options>] <command> [<args>] [<command options>]
    EOS
    COMMANDS = <<~EOS
      The most commonly used gauge commands are:
          create-db   Create a database based on metadata
          check       Check database structure against metadata
          sync        Synchronize database structure regarding the metadata
          help        Displays additional help info

      See 'gauge help <command>' for more information on a specific command
    EOS

    def self.greeting
      HEADER
    end

    def self.version
      "gauge version #{VERSION}"
    end

    def self.help
      HEADER + $/ + COMMANDS
    end
  end
end
