require 'redis'
require 'redis-namespace'

module Blackbeard
  class RedisStore
    attr_reader :redis

    def initialize(r, namespace)
      r ||= Redis.new
      @redis = Redis::Namespace.new(namespace.to_sym, :redis => r)
    end

    def keys
      redis.keys
    end

    def hash_key_set_if_not_exists(hash_key, field, value)
      redis.hsetnx(hash_key, field, value)
    end

    def hash_set(hash_key, field, value)
      redis.hset(hash_key, field, value)
    end

    def hash_length(hash_key)
      redis.hlen(hash_key)
    end

    def hash_keys(hash_key)
      redis.hkeys(hash_key)
    end

    def hash_get_all(hash_key)
      redis.hgetall(hash_key)
    end

    def set_members(set_key)
      redis.smembers(set_key)
    end

    def set_add_member(set_key, member)
      redis.sadd(set_key, member)
    end

    def set_add_members(set_key, *members)
      redis.sadd(set_key, members.flatten)
    end

    def set_count(set_key)
      redis.scard(set_key)
    end

    def del(*keys)
      redis.del(*keys)
    end

    def increment_by_float(key, increment)
      redis.incrbyfloat(key, increment)
    end

    def increment(key)
      redis.incr(key)
    end

    def get(key)
      redis.get(key)
    end

    def multi_get(*keys)
      redis.mget(*keys.flatten)
    end

    def set(key, value)
      redis.set(key, value)
    end

    def set_union_count(keys)
      redis.sunionstore('set_union_count', keys)
    end

  end
end
