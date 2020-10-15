# Eithery, 2020
# DB object search command
# frozen_string_literal: true

module Gauge
  module CLI
    desc 'Performs search for the specified DB object'
    command [:s, :search] do |c|
      c.action do |global_opts, options, args|
        puts 'SEARCH'
        p global_opts
        p options
        p args
      end
    end
  end
end
