# Eithery, 2020
# Global command options
# frozen_string_literal: true

module Gauge
  module CLI
    config_file = File.join(__dir__, '../../config/gauge.rc.yml')
    defaults = YAML.load_file(config_file)

    desc 'Displays help information'
    switch [:h, :help]

    desc 'Displays the application version'
    switch [:v, :version]

    desc 'Database server name'
    default_value defaults[:server] || 'local'
    flag [:s, :server]

    desc 'User name used to connect to db server'
    default_value defaults[:user] || 'admin'
    flag [:u, :user]

    desc 'Password used to connect to db server'
    default_value defaults[:password] || 'secret'
    flag [:p, :password]

    desc 'Path to DB metadata root folder'
    default_value defaults[:data_path] || ['db']
    flag [:d, :data]

    desc 'Use colored console formatter to output messages'
    default_value defaults[:colored] || false
    switch :colored
  end
end
