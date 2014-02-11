require 'tzinfo'
require "blackbeard/redis_store"

module Blackbeard
  class Configuration
    attr_accessor :timezone, :namespace, :redis, :guest_method

    def initialize
      @timezone = 'America/Los_Angeles'
      @namespace = 'Blackbeard'
      @redis = nil
    end

    def db
      @db ||= RedisStore.new(@redis, @namespace)
    end

    def tz
      @tz ||= TZInfo::Timezone.get(@timezone)
    end

  end
end
