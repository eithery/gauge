# Eithery Lab., 2017.
# RSpec helper file.

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'rspec/collection_matchers'
require 'gauge'

Dir[File.join(File.dirname(__FILE__) + '/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
  end
end
