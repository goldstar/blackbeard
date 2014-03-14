module Blackbeard
  class CohortMetric
    include Chartable

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

    def chartable_segments
      metric_data.map{|s| "avg #{s}" }
    end

    def chartable_result_for_hour(hour)
      participants = cohort.data.participants_for_hour(hour)
      result_per_participant( metric_data.result_for_hour(hour), participants)
    end

    def chartable_result_for_day(date)
      participants = cohort.data.participants_for_day(date)
      result_per_participant( metric_data.result_for_day(date), participants)
    end

    def result_per_participant(result, participants)
      participants = participants.to_f
      result.keys.each{|k| result[k] = result[k].to_f / participants }
      result
    end

  end
end
