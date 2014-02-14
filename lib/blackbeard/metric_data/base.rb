require 'blackbeard/metric_hour'
require 'blackbeard/metric_date'
require 'date'

module Blackbeard
  module MetricData
    class Base
      def initialize(metric)
        @metric = metric
      end

      def tz
        @metric.send(:tz)
      end

      def db
        @metric.send(:db)
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
        result = db.get(key) || generate_result_for_day(date)
        result.to_f
      end

    private

      def generate_result_for_day(date)
        date_key = key_for_date(date)
        hours_keys = hour_keys_for_day(date)
        result = merge_results(hours_keys)
        db.set(date_key, result) unless date == Blackbeard.tz.now.to_date
        result
      end


      def hour_keys
        db.set_members(hours_set_key)
      end

      def hours_set_key
        "#{@metric.key}::hours"
      end

      def days_set_key
        "#{@metric.key}::days"
      end

      def key_for_date(date)
        "#{@metric.key}::#{ date.strftime("%Y%m%d") }"
      end

      def key_for_hour(time)
        "#{@metric.key}::#{ time.strftime("%Y%m%d%H") }"
      end

    end
  end
end