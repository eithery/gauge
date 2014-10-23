# Eithery Lab., 2014.
# RSpec helper file.

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'gauge'

Dir[File.join(File.dirname(__FILE__) + '/gauge/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
  end

  config.include Gauge::SchemaMatchers
end
