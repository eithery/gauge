# Eithery, 2020
# Command line interface definitions
# frozen_string_literal: true

require 'gli'

module Gauge
  module CLI
    extend GLI::App

    program_desc 'SQL Server database toolbox'
    subcommand_option_handling :normal
    arguments :strict

    Dir["#{__dir__}/commands/**/*.rb"].sort.each { |f| require f }

    run(ARGV)
  end
end
