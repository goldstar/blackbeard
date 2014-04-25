module Blackbeard
  class Configuration
    attr_accessor :timezone, :namespace, :redis, :guest_method, :announcer
    attr_reader :group_definitions

    def initialize
      @timezone = 'America/Los_Angeles'
      @namespace = 'Blackbeard'
      @group_definitions = {}
      @redis = nil
      @announcer = nil
    end

    def db
      @db ||= RedisStore.new(@redis, @namespace)
    end

    def tz
      @tz ||= TZInfo::Timezone.get(@timezone)
    end

    def on_change(&block)
      @announcer = block
    end

    def define_group(id, segments = nil, &block)
      group = Group.find_or_create(id)
      group.add_segments(segments || id)
      @group_definitions[id.to_sym] = block
    end
  end
end
