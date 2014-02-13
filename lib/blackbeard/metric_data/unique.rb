require 'blackbeard/metric_data/base'

module Blackbeard
  module MetricData
    class Unique < Base

      def add(uid, amount = nil)
        key = key_for_hour(tz.now)
        db.set_add_member(hours_set_key, key)
        db.set_add_member(key, uid)
      end

      def result_for_hour(time)
        key = key_for_hour(time)
        db.set_count(key)
      end

    private

      def merge_results(keys)
        db.set_union_count(keys)
      end
    end
  end
end

