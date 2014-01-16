require "blackbeard/metric"

module Blackbeard
  class Metric::Unique < Metric

    def add(uid)
      key = key_for_hour(tz.now)
      db.set_add_member(hours_set_key, key)
      db.set_add_member(key, uid)
    end

    def result_for_hour_key(key)
      db.set_count(key)
    end

  end
end

