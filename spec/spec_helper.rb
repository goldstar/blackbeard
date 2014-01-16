require 'blackbeard'
require 'redis'

RSpec.configure do |config|
  config.before do
    redis = Blackbeard.db
    keys = redis.keys
    redis.del(keys) if keys.any?
  end
end
