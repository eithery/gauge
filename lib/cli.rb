# Eithery, 2020
# The application main entry point
# frozen_string_literal: true

require_relative 'gauge'

module Gauge
  class CLI < Thor
    extend CommandHelper
    Dir["#{__dir__}/commands/**/*.rb"].each { |f| require f }
  end
end
