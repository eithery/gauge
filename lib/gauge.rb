# Eithery Lab, 2017.
# Loads files for the applicaion.

require 'active_support/core_ext/string'
require 'active_support/core_ext/string/inflections'

require 'gli'
require 'rainbow'
require 'rainbow/ext/string'
require 'rexml/document'
require 'sequel'

load_path = File.expand_path(File.dirname(__FILE__) + '/../lib')

Dir["#{load_path}/gauge/**/*.rb"].each { |f| require f }
Dir["#{load_path}/ext/ruby/*.rb"].each { |f| require f }
Dir["#{load_path}/sequel/tinytds/*.rb"].each { |f| require f }
