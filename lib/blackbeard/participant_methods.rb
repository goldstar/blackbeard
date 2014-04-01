module Blackbeard
  module ParticipantMethods

    def value_for_participant(uid)
      db.hash_get(participants_hash_key, uid)
    end

    def participants_for_hour(time)
      db.hash_get(hours_hash_key, hour_id(time)).to_i
    end

    def participants_for_day(date)
      start_of_day = date.to_time
      hours_in_day = Array(0..23).map{|x| start_of_day + (3600 * x) }
      participants_by_hour = participants_for_hours(hours_in_day)
      participants_by_hour.reduce(:+)
    end

    def participants_for_hours(hours)
      hour_ids = hours.map{ |hour| hour_id(hour) }
      db.hash_multi_get(hours_hash_key, *hour_ids).map{|s| s.to_i }
    end

  private

    def hour_id(time)
      time.strftime("%Y%m%d%H")
    end

    def hours_hash_key
      @hours_hash_key ||= "#{key}::hours"
    end

    def participants_hash_key
      @hours_hash_key ||= "#{key}::participants"
    end

  end
end
