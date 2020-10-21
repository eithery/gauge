# Eithery, 2020
# Displays the application version
# frozen_string_literal: true

module Gauge
  class CLI < Thor
    desc 'version', 'Display the application version'
    map %w[-v --version] => :version

    def version
      puts AppInfo.version
    end
  end
end
