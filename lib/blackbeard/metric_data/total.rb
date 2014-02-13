require 'blackbeard/metric_data/base'

module Blackbeard
  module MetricData
    class Total < Base

      def add(uid, amount = 1)
        key = key_for_hour(tz.now)
        db.set_add_member(hours_set_key, key)
        db.increment_by_float(key, amount.to_f)
      end

      def result_for_hour(time)
        key = key_for_hour(time)
        db.get(key).to_f
      end

    private

      def merge_results(keys)
        db.multi_get(keys).map(&:to_f).inject(:+) # .sum
      end
    end
  end
end
