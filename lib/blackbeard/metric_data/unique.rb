require 'blackbeard/metric_data/base'

module Blackbeard
  module MetricData
    class Unique < Base

      DEFAULT_SEGMENT = 'uniques'
      def add(uid, amount = nil, segment = DEFAULT_SEGMENT)
        key = key_for_hour(tz.now)
        segment_key = segment_key(key, segment)

        db.set_add_member(hours_set_key, key)
        db.set_add_member(key, segment_key)
        db.set_add_member(segment_key, uid)
      end

      def result_for_hour(time, segment = DEFAULT_SEGMENT)
        key = key_for_hour(time)
        segment_key = segment_key(key, segment)
        db.set_count(segment_key)
      end

      def segment_key(key, segment)
        "#{key}::#{segment}"
      end

    private

      def merge_results(keys)
        db.set_union_count(keys)
      end
    end
  end
end

