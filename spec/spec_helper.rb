$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'caerbannog'
require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end
