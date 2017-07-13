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

    def last_status_for(uid)
      db.hash_get(participants_hash_key, uid)
    end

    def destroy
      db.hash_del_all(hours_hash_key)
      db.hash_del_all(participants_hash_key)
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
