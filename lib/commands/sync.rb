# Eithery, 2020
# Database sync command
# frozen_string_literal: true

module Gauge
  class CLI
    desc 'sync', 'Perform DB synchronization based on the predefined metadata'

    command :sync do
      puts 'SYNC DATABASE'
    end
  end
end
