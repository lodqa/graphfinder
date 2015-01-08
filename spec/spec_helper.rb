require 'rack/test'
require 'rspec'

require 'graphfinder'
require 'graphfinder_ws'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() GraphFinderWS end
end

# For RSpec 2.x
RSpec.configure { |c| c.include RSpecMixin }
