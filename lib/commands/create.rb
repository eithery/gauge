# Eithery, 2020
# Create database command
# frozen_string_literal: true

module Gauge
  class CLI < Thor
    desc 'create', 'Create a new database based on the schema metadata'
    method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
    def create
      if options[:help]
        invoke :help, ['create']
      else
        puts 'CREATE'
      end
    end
  end
end
