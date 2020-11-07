# Eithery, 2020
# Global command options
# frozen_string_literal: true

module Gauge
  class CLI
    config_file = File.join(__dir__, '../../config/gauge.rc.yml')
    defaults = ::YAML.load_file(config_file)

    class_option :server, desc: 'Database server name',
      aliases: ['-s'], default: defaults[:server] || 'local'
    class_option :user, desc: 'User name to connect to db server',
      aliases: ['-u'], default: defaults[:user] || 'sa'
    class_option :password, desc: 'Password used to connect to db server',
      aliases: ['-p'], default: defaults[:password]
    class_option :data, desc: 'Path to DB metadata root directory',
      aliases: ['-d'], default: defaults[:data_path] || 'db'
    class_option :colored, desc: 'Use colored console formatter to output messages',
      type: :boolean, aliases: ['-c'], default: false
  end
end
