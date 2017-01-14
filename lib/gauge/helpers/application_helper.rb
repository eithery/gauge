# Eithery Lab, 2017
# Class Gauge::ApplicationHelper
# Provides helper methods for the application.

require 'gauge'

class ApplicationHelper
  def self.root_path
    File.expand_path(File.dirname(__FILE__) + '/../../../')
  end


  def self.db_path
    File.expand_path(root_path + '/db/')
  end
end
