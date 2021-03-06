module Blackbeard
  module MetricData
    class Base
      include ConfigurationMethods

      attr_reader :metric, :metric_for

      def initialize(metric, metric_for = nil)
        @metric = metric
        @metric_for = metric_for
      end

      def hour_keys_for_day(date)
        start_of_day = date.to_time
        Array(0..23).map{|x| start_of_day + (3600 * x) }.map{|t| key_for_hour(t) }
      end

      def result_for_day(date)
        key = key_for_date(date)
        result = db.hash_get_all(key)
        result = generate_result_for_day(date) if result.empty?
        result.each { |k,v| result[k] = v.to_f }
        result
      end

      def key
        @key ||= begin
          "data::#{uid}"
        end
      end

      def uid
        uid = UidGenerator.new(self).uid
      end

      def segments
        [self.class::DEFAULT_SEGMENT]
      end

    private

      def generate_result_for_day(date)
        date_key = key_for_date(date)
        hours_keys = hour_keys_for_day(date)
        result = merge_results(hours_keys)
        # TODO: update days_set_key
        db.hash_multi_set(date_key, result) unless date == tz.now.to_date
        result
      end

      def hour_keys
        db.set_members(hours_set_key)
      end

      def hours_set_key
        "#{key}::hours"
      end

      def days_set_key
        "#{key}::days"
      end

      def key_for_date(date)
        "#{key}::#{ date.strftime("%Y%m%d") }"
      end

      def key_for_hour(time)
        if time.kind_of?(Time)
          time = time.strftime("%Y%m%d%H")
        end
        "#{key}::#{ time }"
      end

    end
  end
end
