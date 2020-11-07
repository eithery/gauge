# Eithery, 2020
# Bootstraps the application
# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'active_support/core_ext/string/inflections'
require 'thor'
require 'yaml'
# require 'rainbow'
# require 'rainbow/ext/string'

require_relative 'gauge/version'
require_relative 'gauge/app_info'
require_relative 'gauge/command_helper'
