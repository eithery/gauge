# Eithery Lab, 2017
# Module Gauge::ApplicationHelper
# Provides helper methods for the application.

require 'gauge'

module Gauge
  module ApplicationHelper

    def self.root_path
      File.expand_path('../../../../', __FILE__)
    end


    def self.db_home
      root_path + '/db'
    end


    def self.sql_home
      root_path + '/sql'
    end
  end
end
