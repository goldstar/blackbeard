require 'blackbeard/storable'
require 'date'

module Blackbeard
  class Cohort < Storable
    set_master_key :cohorts
    string_attributes :name, :description

    def add(context, timestamp = nil, force = false)
      save if new_record?
      uid = context.unique_identifier
      #TODO: Make sure timestamp is in correct tz
      timestamp ||= tz.now
      return (force) ? add_with_force(uid, timestamp) : add_without_force(uid, timestamp)
    end

    def name
      storable_attributes_hash['name'] || id
    end

    def hour_id_for_participant(uid)
      db.hash_get(participants_hash_key, uid)
    end

    def participants_for_hour(time)
      db.hash_get(hours_hash_key, hour_id(time)).to_i
    end

    def participants_for_day(date)
      start_of_day = date.to_time
      hours_in_day = Array(0..23).map{|x| start_of_day + (3600 * x) }
      participants_by_hour = participants_for_hours(hours_in_day)
      participants_by_hour.inject{|s,n| s += n.to_i} # sum
    end

    def participants_for_hours(hours)
      hour_ids = hours.map{ |hour| hour_id(hour) }
      db.hash_multi_get(hours_hash_key, *hour_ids).map{|s| s.to_i }
    end

    def recent_days(count=28, starting_on = tz.now.to_date)
      Array(0..count-1).map do |offset|
        date = starting_on - offset
        result = participants_for_day(date)
        Blackbeard::MetricDate.new(date, result)
      end
    end

    def recent_hours(count = 24, starting_at = tz.now)
      Array(0..count-1).map do |offset|
        hour = starting_at - (offset * 3600)
        result = participants_for_hour(hour)
        Blackbeard::MetricHour.new(hour, result)
      end
    end

  private

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
