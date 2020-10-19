# Eithery, 2020
# Bootstraps the application
# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'active_support/core_ext/string/inflections'
require 'rainbow'
require 'rainbow/ext/string'

require_relative 'gauge/shell'
require_relative 'gauge/app_info'
require_relative 'gauge/global_options'

# Dir["#{__dir__}/gauge/**/*.rb"].each { |f| require f }
