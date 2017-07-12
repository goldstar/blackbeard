require 'blackbeard'
require 'redis'

RSpec.configure do |config|
  config.before do
    Blackbeard.configure! do |c|
      c.namespace = "BlackbeardTests"
    end
    redis = Blackbeard.config.db.redis
    redis.scan_each { |k| redis.del(k) }
  end
end

def tz
  Blackbeard.config.tz
end

def db
  Blackbeard.config.db
end
