# Eithery, 2020
# Database sync command
# frozen_string_literal: true

module Gauge
  class CLI < Thor
    desc 'sync', 'Perform DB synchronization based on the predefined metadata'
    method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'

    def sync
      if options[:help]
        invoke :help, ['sync']
      else
        puts 'SYNC DATABASE'
      end
    end
  end
end
