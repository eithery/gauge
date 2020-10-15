# Eithery, 2020
# Help command
# frozen_string_literal: true

module Gauge
  module CLI
    desc 'Displays help information'
    command [:k, :kva] do |c|
      c.action do |global_opts, options, args|
        puts 'HELP'
        p global_opts
        p options
        p args
        # Gauge::Shell.new.help global_opts
      end
    end
  end
end
