require 'blackbeard'
require 'redis'
require "codeclimate-test-reporter"
require 'coveralls'

Coveralls.wear!
CodeClimate::TestReporter.start

RSpec.configure do |config|
  config.before do
    redis = Blackbeard.config.db
    keys = redis.keys
    redis.del(keys) if keys.any?
  end
end

def tz
  Blackbeard.config.tz
end

def db
  Blackbeard.config.db
end
