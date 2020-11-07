# Eithery, 2020
# DB object search command
# frozen_string_literal: true

module Gauge
  class CLI
    desc 'search', 'Perform search for the specified DB object'

    command :search, :s do
      puts 'SEARCH DB OBJECT'
    end
  end
end
