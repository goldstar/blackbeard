module Blackbeard
  module MetricData
    class Unique < Base

      DEFAULT_SEGMENT = 'uniques'
      def add(uid, amount = nil, segment = DEFAULT_SEGMENT)
        add_at(tz.now, uid, amount, segment)
      end

      def add_at(time, uid, amount = nil, segment = DEFAULT_SEGMENT)
        #TODO: unsure time is in proper timezone
        key = key_for_hour(time)
        segment_key = segment_key(key, segment)

        db.set_add_member(hours_set_key, key)
        db.set_add_member(key, segment_key)
        db.set_add_member(segment_key, uid)
        #TODO: if not today, blow away rollup keys
      end

      def result_for_hour(time)
        key = key_for_hour(time)
        segment_keys = db.set_members(key)
        result = {}
        segment_keys.each do |segment_key|
          segment = segment_key.split(/::/).last
          result[segment] = db.set_count(segment_key)
        end
        result
      end

      def segment_key(key, segment)
        "#{key}::#{segment}"
      end

    private

      def merge_results(keys)
        segments = {}
        keys.each do |key|
          segment_keys = db.set_members(key)
          segment_keys.each do |segment_key|
            segment = segment_key.split(/::/).last
            segments[segment] ||= []
            segments[segment].push(segment_key)
          end
        end
        merged_results = {}
        segments.each do |segment, segment_keys|
          merged_results[segment] = db.set_union_count(segment_keys)
        end
        merged_results
      end
    end
  end
end
