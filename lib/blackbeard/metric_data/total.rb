require 'blackbeard/metric_data/base'

module Blackbeard
  module MetricData
    class Total < Base

      DEFAULT_SEGMENT = 'total'

      def add(uid, amount = 1, segment = DEFAULT_SEGMENT)
        key = key_for_hour(tz.now)
        db.set_add_member(hours_set_key, key)
        db.hash_increment_by_float(key, segment, amount.to_f)
      end

      def result_for_hour(time, segment = DEFAULT_SEGMENT)
        key = key_for_hour(time)
        db.hash_get(key, segment).to_f
      end

    private

      def merge_results(keys)
        db.multi_get(keys).map(&:to_f).inject(:+) # .sum
      end
    end
  end
end
