require 'tzinfo'
require "blackbeard/redis_store"

module Blackbeard
  class Configuration
    attr_accessor :timezone, :namespace, :redis, :unique_identifier

    def initialize
      @timezone = 'America/Los_Angeles'
      @namespace = 'Blackbeard'
      @redis = nil
      @unique_identifier = nil
    end

    def db
      @db ||= RedisStore.new(@redis, @namespace)
    end

    def tz
      @tz ||= TZInfo::Timezone.get(@timezone)
    end

    def unique_identifier
      @unique_identifier.call
    end

  end
end
