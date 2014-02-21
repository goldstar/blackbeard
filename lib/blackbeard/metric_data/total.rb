require 'blackbeard/metric_data/base'

module Blackbeard
  module MetricData
    class Total < Base

      DEFAULT_SEGMENT = 'total'

      def add(uid, amount = 1, segment = DEFAULT_SEGMENT)
        add_at(tz.now, uid, amount, segment)
      end

      def add_at(time, uid, amount = 1, segment = DEFAULT_SEGMENT)
        key = key_for_hour(time)
        db.set_add_member(hours_set_key, key)
        db.hash_increment_by_float(key, segment, amount.to_f)
        #TODO: if not today, blow away rollup keys
      end

      def result_for_hour(time)
        key = key_for_hour(time)
        result = db.hash_get_all(key)
        result.each{ |k,v| result[k] = v.to_f }
        result
      end

    private

      def merge_results(keys)
        merged_results = {}
        keys.each do |key|
          result = db.hash_get_all(key)
          result.each{ |k,v| merged_results[k] ||= 0; merged_results[k] += v.to_f}
        end
        merged_results
      end
    end
  end
end
