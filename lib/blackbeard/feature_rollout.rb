module Blackbeard
  module FeatureRollout
    def rollout?(context)
      active_user?(context) || active_visitor?(context) || active_segment?(context)
    end

    def active_segment?(context)
      return false unless group_segments
      #TODO: speed this up. memoize group on the feature. store segment in user session
      group_segments.each_pair do |group_id, segments|
        next if segments.nil? || segments.empty?
        group = Group.find(group_id) or next
        user_segment = group.segment_for(context) or next
        return true if segments.include?(user_segment)
      end
      false
    end

    def active_user?(context)
      return false if (users_rate.zero? || context.user.nil?)
      return true if users_rate == 100

      user_id = id_to_int(context.user_id)
      threshold_moduli[user_id % 100].between?(0,users_rate)
    end

    def active_visitor?(context)
      return false if visitors_rate.zero?
      return true if visitors_rate == 100

      threshold_moduli[context.visitor_id % 100].between?(0,visitors_rate)
    end

    def id_to_int(id)
      if id.kind_of?(Integer)
        id
      elsif id.kind_of?(String)
        bytes = id.bytes
        if bytes.count > 8
          bytes = bytes[-8..-1]
        end
        bytes.inject { |sum, n| sum * n }
      else
        raise UserIdNotDivisable
      end
    end
  end
end

