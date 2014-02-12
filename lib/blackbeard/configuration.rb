require 'tzinfo'
require "blackbeard/redis_store"
require "blackbeard/group"

module Blackbeard
  class Configuration
    attr_accessor :timezone, :namespace, :redis, :guest_method
    attr_reader :group_definitions

    def initialize
      @timezone = 'America/Los_Angeles'
      @namespace = 'Blackbeard'
      @group_definitions = {}
      @redis = nil
    end

    def db
      @db ||= RedisStore.new(@redis, @namespace)
    end

    def tz
      @tz ||= TZInfo::Timezone.get(@timezone)
    end

    def define_group(id, &block)
      @group_definitions[id.to_sym] = block
      Group.new(id)
    end
  end
end
