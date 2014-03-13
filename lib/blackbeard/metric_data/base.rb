require 'blackbeard/metric_hour'
require 'blackbeard/metric_date'
require 'date'
require 'blackbeard/chart'
require 'blackbeard/metric_data/uid_generator'
require 'blackbeard/chartable'

module Blackbeard
  module MetricData
    class Base
      include ConfigurationMethods
      include Chartable

      attr_reader :metric, :group, :cohort

      # TODO: refactor so you pass group and cohort in as options
      def initialize(metric, group = nil, cohort = nil)
        @metric = metric
        @group = group
        @cohort = cohort
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
