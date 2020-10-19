# Eithery, 2020
# Help command
# frozen_string_literal: true

module Gauge
  module CLI
    desc 'Displays help information'
    command [:h, :help] do |c|
      c.action do |global_opts|
        puts Gauge::Shell.new(global_opts).app_info
      end
    end
  end
end
