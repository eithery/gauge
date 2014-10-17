# Eithery Lab., 2014.
# RSpec helper file.

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'gauge'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
