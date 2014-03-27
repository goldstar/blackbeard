require 'blackbeard/storable'
require 'blackbeard/feature_rollout'
module Blackbeard
  class Feature < Storable
    include FeatureRollout

    set_master_key :features
    string_attributes :name, :description, :status
    integer_attributes :visitors_rate, :users_rate
    json_attributes :group_segments

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
      set_feature_segment(context.unique_identifier, active)
      active
    end



    def status
      storable_attributes_hash['status'] || "inactive"
    end

    def name
      storable_attributes_hash['name'] || id
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
