module Blackbeard
  class SegmentedMetric
    include ConfigurationMethods
    include Chartable

    attr_reader :group, :metric

    def initialize(group, metric)
      @group = group
      @metric = metric
    end

    def type
      metric.type
    end

    def add(context, amount)
      uid = context.unique_identifier
      segment = group.segment_for(context)
      metric_data.add(uid, amount, segment) unless segment.nil?
    end

    def metric_data
      @metric_data ||= MetricData.const_get(type.capitalize).new(metric, group)
    end

    def chartable_segments
      group.segments
    end

    def chartable_result_for_hour(hour)
      metric_data.result_for_hour(hour)
    end

    def chartable_result_for_day(date)
      metric_data.result_for_day(date)
    end

  end
end
