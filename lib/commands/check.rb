# Eithery, 2020
# Database schema check command
# frozen_string_literal: true

module Gauge
  class CLI
    desc 'check', 'Compare DB schema against the predefined metadata'

    command :check, :c do
      puts 'CHECK DATABASE!'
    end
  end
end
