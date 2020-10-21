# Eithery, 2020
# DB object search command
# frozen_string_literal: true

module Gauge
  class CLI < Thor
    desc 'search', 'Perform search for the specified DB object'
    method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
    map ['s'] => :search

    def search
      if options[:help]
        invoke :help, ['search']
      else
        puts 'SEARCH DB OBJECT'
      end
    end
  end
end
