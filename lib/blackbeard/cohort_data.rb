require 'date'
require 'blackbeard/participant_methods'

module Blackbeard
  class CohortData
    include ConfigurationMethods
    include ParticipantMethods

    def initialize(cohort)
      @cohort = cohort
    end

    def hour_id_for_participant(uid)
      value_for_participant(uid)
    end

    def add_with_force(uid, hour)
      prior_hour_id = db.hash_get(participants_hash_key, uid)

      # Force not necessary
      return add_without_force(uid, hour) unless prior_hour_id

      hour_id = hour_id(hour)
      # No change in cohort status
      return true if prior_hour_id == hour_id

      # Deincrement old, increment new
      db.hash_increment_by(hours_hash_key, prior_hour_id, -1)
      db.hash_increment_by(hours_hash_key, hour_id, 1)
      db.hash_set(participants_hash_key, uid, hour_id)
      true
    end

    def add_without_force(uid, hour)
      hour_id = hour_id(hour)
      # Check if uid is alreaty in cohort
      return false unless db.hash_set_if_not_exists(participants_hash_key, uid, hour_id)
      db.hash_increment_by(hours_hash_key, hour_id, 1)
      true
    end

  private

    def key
      @cohort.key
    end

  end
end
