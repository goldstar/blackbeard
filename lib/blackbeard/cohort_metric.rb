module Blackbeard
  class CohortMetric
    attr_reader :cohort, :metric

    def initialize(cohort, metric)
      @cohort = cohort
      @metric = metric
    end

    def type
      metric.type
    end

    def add(context, amount)
      uid = context.unique_identifier
      hour_id = cohort.hour_id_for_participant(uid)
      metric_data.add_at(hour_id, uid, amount) unless hour_id.nil?
    end

    def metric_data
      @metric_data ||= MetricData.const_get(type.capitalize).new(metric, nil, cohort)
    end
  end
end
