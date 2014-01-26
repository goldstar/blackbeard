require 'blackbeard'
require 'redis'
require 'byebug'

RSpec.configure do |config|
  config.before do
    redis = Blackbeard.db
    keys = redis.keys
    redis.del(keys) if keys.any?
  end
end
