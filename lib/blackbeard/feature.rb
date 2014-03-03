require 'blackbeard/storable'

module Blackbeard
  class Feature < Storable
    set_master_key :features
    string_attributes :name, :description, :status
    integer_attributes :visitors_rate, :users_rate
    json_attributes :group_segments

    def segments_for(group_id)
      (group_segments && group_segments[group_id.to_s]) || []
    end

    def set_segments_for(group_id, *segments)
      segments = Array(segments).flatten.compact.map{|a| a.to_s}
      grp_segments = self.group_segments || {}
      grp_segments[group_id.to_s] = segments
      self.group_segments = grp_segments
    end

    def active_for?(context)
      case status
      when 'active'
        true
      when 'rollout'
        active_user?(context) || active_visitor?(context) || in_active_segment?(context)
      else
        false
      end
    end

    def inactive_segment?(context)
      false
    end

    def active_user?(context)
      false
    end

    def active_visitor?(context)
      false
    end

    def status
      storable_attributes_hash['status'] || "inactive"
    end

    def name
      storable_attributes_hash['name'] || id
    end

  private

  end
end
