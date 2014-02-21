require 'blackbeard/metric_hour'
require 'blackbeard/metric_date'
require 'date'

module Blackbeard
  module MetricData
    class Base
      include ConfigurationMethods
      attr_reader :metric, :group

      def initialize(metric, group = nil)
        @metric = metric
        @group = group
      end

      def recent_days(count=28, starting_on = tz.now.to_date)
        Array(0..count-1).map do |offset|
          date = starting_on - offset
          result = result_for_day(date)
          Blackbeard::MetricDate.new(date, result)
        end
      end

      def recent_hours(count = 24, starting_at = tz.now)
        Array(0..count-1).map do |offset|
          hour = starting_at - (offset * 3600)
          result = result_for_hour(hour)
          Blackbeard::MetricHour.new(hour, result)
        end
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
          lookup_hash = "metric_data_keys"
          lookup_field = "metric-#{metric.id}"
          lookup_field += "::group-#{group.id}" if group
          uid = db.hash_get(lookup_hash, lookup_field)
          if uid.nil?
            uid = db.increment("metric_data_next_uid")
            # write and read to avoid race conditional writes
            db.hash_key_set_if_not_exists(lookup_hash, lookup_field, uid)
            uid = db.hash_get(lookup_hash, lookup_field)
          end
          "data::#{uid}"
        end
      end

      def segments
        if group && group.segments.any?
          group.segments
        else
          [self.class::DEFAULT_SEGMENT]
        end
      end
    private

      def generate_result_for_day(date)
        date_key = key_for_date(date)
        hours_keys = hour_keys_for_day(date)
        result = merge_results(hours_keys)
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
        "#{key}::#{ time.strftime("%Y%m%d%H") }"
      end

    end
  end
end
