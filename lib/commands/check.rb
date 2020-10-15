# Eithery, 2020
# Database schema check command
# frozen_string_literal: true

module Gauge
  module CLI
    desc 'Compares DB schema against the predefined metadata'
    command [:c, :check] do |c|
      c.action do |global_opts, options, args|
        puts 'CHECK'
        p global_opts
        p options
        p args
        # Gauge::Shell.new.check global_opts, options, args
      end
    end
  end
end
