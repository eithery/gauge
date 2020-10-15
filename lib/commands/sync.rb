# Eithery, 2020
# Database sync command
# frozen_string_literal: true

module Gauge
  module CLI
    desc 'Performs DB synchronization based on the predefined metadata'
    command :sync do |c|
      c.action do |global_opts, options, args|
        puts 'SYNC'
        p global_opts
        p options
        p args
        # Gauge::Shell.new.sync global_opts, options, args
      end
    end
  end
end
