# Eithery, 2020
# Displays the application version
# frozen_string_literal: true

module Gauge
  class CLI
    desc 'version', 'Display the application version'
    map %w[-v --version] => :version

    def version
      puts "Gauge version #{VERSION}"
    end
  end
end
