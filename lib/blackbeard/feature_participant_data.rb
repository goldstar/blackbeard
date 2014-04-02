module Blackbeard
  class FeatureBaseParticipantData
    include ConfigurationMethods
    include ParticipantMethods

    def initialize(feature)
      @feature = feature
    end

    def add(uid, hour)
      hour_id = hour_id(hour)
      db.hash_increment_by(hours_hash_key, hour_id, 1)
      db.hash_set(participants_hash_key, uid, status)
    end

  private

    def key
      @feature.key
    end

    def hours_hash_key
      @hours_hash_key ||= "#{key}::#{status}::hours"
    end

  end

  class FeatureActiveParticipantData < FeatureBaseParticipantData
    def status
      :active
    end
  end

  class FeatureInactiveParticipantData < FeatureBaseParticipantData
    def status
      :inactive
    end
  end
end
