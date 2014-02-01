require "blackbeard/storable"

module Blackbeard
  class Metric < Storable
    set_master_key :metrics
    string_attributes :name

    def initialize(id)
      raise "do not create a Metric directly. Instead use a subclass." if self.class == Blackbeard::Metric
      super
    end

    def self.new_from_type_id(type, id)
      self.const_get(type.capitalize).new(id)
    end

    def type
      self.class.name.split("::").last.downcase
    end

    def name
      storable_attributes_hash[:name] || id
    end

    def self.new_from_key(key)
      if key =~ /^metrics::(.+)::(.+)$/
        new_from_type_id($1, $2)
      else
        nil
      end
    end

    def key
      "metrics::#{ type }::#{ id }"
    end

    def recent_hours(count = 24, starting_at = tz.now)
      Array(0..count-1).map do |offset|
        hour = starting_at - (offset * 3600)
        result = result_for_hour(hour)
        {:hour => hour.strftime("%Y%m%d%H"), :result => result}
      end
    end

    def hours
      hour_keys.map do |hour_key|
        {
          :hour => hour_key.split("::").last,
          :result => result_for_hour_key(hour_key)
        }
      end
    end

    def result_for_hour(time)
      key = key_for_hour(time)
      result_for_hour_key(key)
    end

private

    def hour_keys
      db.set_members(hours_set_key)
    end

    def hours_set_key
      "#{key}::hours"
    end

    def key_for_hour(time)
      "#{key}::#{ time.strftime("%Y%m%d%H") }"
    end

  end
end
