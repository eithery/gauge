# Eithery, 2020
# Database schema check command
# frozen_string_literal: true

module Gauge
  class CLI < Thor
    desc 'check', 'Compare DB schema against the predefined metadata'
    method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
    map ['c'] => :check

    def check
      if options[:help]
        invoke :help, ['check']
      else
        puts 'CHECK DATABASE'
      end
    end
  end
end
