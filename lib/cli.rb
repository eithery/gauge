# Eithery, 2020
# The application main entry point
# frozen_string_literal: true

require_relative 'gauge'
Dir["#{__dir__}/commands/**/*.rb"].each { |f| require f }
