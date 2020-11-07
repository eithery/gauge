# Eithery, 2020
# Create database command
# frozen_string_literal: true

module Gauge
  class CLI
    desc 'create', 'Create a new database based on the schema metadata'

    command :create do
      puts 'CREATE DATABASE'
    end
  end
end
