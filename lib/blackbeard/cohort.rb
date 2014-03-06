require 'blackbeard/storable'
module Blackbeard
  class Cohort < Storable
    set_master_key :cohorts
    string_attributes :name, :description

    def add(context, timestamp = nil, force = false)
      save if new_record?
      uid = context.unique_identifier
      #TODO: Make sure timestamp is in correct tz
      timestamp ||= tz.now
      hour_id = field_for_hour(timestamp)

      return (force) ? add_with_force(uid, hour_id) : add_without_force(uid, hour_id)
    end

    def name
      storable_attributes_hash['name'] || id
    end

    def hour_id_for_participant(uid)
      db.hash_get(participants_hash_key, uid)
    end

    def participants_for_hour(hour_id)
      db.hash_get(hours_hash_key, hour_id).to_i
    end

  private

    def add_with_force(uid, hour_id)
      prior_hour_id = db.hash_get(participants_hash_key, uid)

      # Force not necessary
      return add_without_force(uid, hour_id) unless prior_hour_id

      # No change in cohort status
      return true if prior_hour_id == hour_id

      # Deincrement old, increment new
      db.hash_increment_by(hours_hash_key, prior_hour_id, -1)
      db.hash_increment_by(hours_hash_key, hour_id, 1)
      db.hash_set(participants_hash_key, uid, hour_id)
      true
    end

    def add_without_force(uid, hour_id)
      return false unless db.hash_key_set_if_not_exists(participants_hash_key, uid, hour_id)
      db.hash_increment_by(hours_hash_key, hour_id, 1)
      true
    end

    def hour_id(time)
      time.strftime("%Y%m%d%H")
    end

    def hours_hash_key
      "#{key}::hours"
    end

    def participants_hash_key
      "#{key}::participants"
    end

  end
end
