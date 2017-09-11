module Blackbeard
  class AppRevisionBaseParticipantData
    include ConfigurationMethods
    include ParticipantMethods

    def initialize(revision)
      @revision = revision
    end

    def add(uid, hour)
      hour_id = hour_id(hour)
      db.hash_increment_by(hours_hash_key, hour_id, 1)
      db.hash_set(participants_hash_key, uid, status)
    end

    def last_status_for(uid)
      db.hash_get(participants_hash_key, uid)
    end

    private

    def key
      @revision.to_s
    end

    def hours_hash_key
      @hours_hash_key ||= "#{key}::#{status}::hours"
    end

  end

  class AppRevisionNewerParticipantData < AppRevisionBaseParticipantData
    def status
      :newer
    end
  end

  class AppRevisionOlderParticipantData < AppRevisionBaseParticipantData
    def status
      :older
    end
  end
end

