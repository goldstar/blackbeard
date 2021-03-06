module Blackbeard
  class Cohort < Storable
    include Chartable

    set_master_key :cohorts
    string_attributes :name, :description

    def add(context, timestamp = nil, force = false)
      save if new_record?
      uid = context.unique_identifier
      #TODO: Make sure timestamp is in correct tz
      timestamp ||= tz.now
      return (force) ? data.add_with_force(uid, timestamp) : data.add_without_force(uid, timestamp)
    end

    def data
      @data ||= CohortData.new(self)
    end

    def metric_data(metric)
      CohortMetric.new(self,metric).metric_data
    end

    def hour_id_for_participant(uid)
      data.hour_id_for_participant(uid)
    end

    def chartable_segments
      ['participants']
    end

    def chartable_result_for_hour(hour)
      {'participants' => data.participants_for_hour(hour) }
    end

    def chartable_result_for_day(date)
      {'participants' => data.participants_for_day(date) }
    end

  end
end
