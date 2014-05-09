require 'gauge'

module Gauge
  class Repo
    def initialize
      @data_root = File.expand_path(File.dirname(__FILE__) + '/../../db')
    end


    # Determines whether the specified name represents the name of a database
    def database?(dbo_name)
      Dir.exist?("#{@data_root}/#{dbo_name}")
    end


    # Determines whether the specified name represents the name of data table
    def table?(dbo_name)
      Dir["#{@data_root}/**/tables/**/#{dbo_name}.db.xml"].any?
    end
  end
end
