module Blackbeard
  class Feature < Storable
    include FeatureRollout
    include Chartable

    set_master_key :features
    string_attributes :name, :description, :status
    integer_attributes :visitors_rate, :users_rate
    json_attributes :group_segments

    has_many :metrics => 'Metric'

    def group_segments_for(group_id)
      (group_segments && group_segments[group_id.to_s]) || []
    end

    def set_group_segments_for(group_id, *segments)
      segments = Array(segments).flatten.compact.map{|a| a.to_s}
      grp_segments = self.group_segments || {}
      grp_segments[group_id.to_s] = segments
      self.group_segments = grp_segments
    end

    def active_for?(context)
      active = active?(context)
      participant_data = active ? active_participant_data : inactive_participant_data
      participant_data.add(context.unique_identifier, tz.now)
      active
    end

    def active_participant_data
      @active_data ||= FeatureActiveParticipantData.new(self)
    end

    def inactive_participant_data
      @inactive_data ||= FeatureInactiveParticipantData.new(self)
    end

    def status
      storable_attributes_hash['status'] || "inactive"
    end

    def name
      storable_attributes_hash['name'] || id
    end

    def segment_for(context)
      active_for?(context) ? 'active_requests' : 'inactive_requests'
    end

    def segments
      ['active_requests', 'inactive_requests']
    end

    def chartable_segments
      segments
    end

    def chartable_result_for_hour(hour)
      {
        'active_requests' => active_participant_data.participants_for_hour(hour),
        'inactive_requests' => inactive_participant_data.participants_for_hour(hour)
      }
    end

    def chartable_result_for_day(date)
      {
        'active_requests' => active_participant_data.participants_for_day(date),
        'inactive_requests' => inactive_participant_data.participants_for_day(date)
      }
    end

    def addable_metrics
      Metric.all.reject{ |m| metric_ids.include?(m.id) }
    end

    def metric_data(metric)
      FeatureMetric.new(self,metric).metric_data
    end

  private

    def active?(context)
      case status
      when 'active'
        true
      when 'rollout'
        rollout?(context)
      else
        false
      end
    end


  end
end
