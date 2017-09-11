module Blackbeard
  class Configuration
    attr_accessor :timezone, :namespace, :redis, :guest_method, :announcer, :revision_header
    attr_reader :group_definitions, :parse_revision_proc

    DEFAULT_PARSE_REVISION_PROC = ->(rev) {
      return '0.00' if rev.nil?

      if String(rev)['.'].nil?
        "#{rev}.00"
      else
        String(rev)
      end
    }

    def initialize
      @timezone = 'America/Los_Angeles'
      @namespace = 'Blackbeard'
      @group_definitions = {}
      @redis = nil
      @announcer = nil
      @revision_header = nil
      @parse_revision_proc = DEFAULT_PARSE_REVISION_PROC
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

    def to_parse_revision(&block)
      @parse_revision_proc = block
    end

    def define_group(id, segments = nil, &block)
      group = Group.find_or_create(id)
      group.add_segments(segments || id)
      @group_definitions[id.to_sym] = block
    end
  end
end
