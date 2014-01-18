require "blackbeard/storable"

module Blackbeard
  class Metric < Storable

    def self.new_from_type_name(type, name)
      self.const_get(type.capitalize).new(name)
    end

    def type
      self.class.name.split("::").last.downcase
    end

    def self.master_key
      "metrics"
    end

    def self.new_from_key(key)
      if key =~ /^metrics::(.+)::(.+)$/
        new_from_type_name($1, $2)
      else
        nil
      end
    end

    def key
      "metrics::#{ type }::#{ name }"
    end

    def hours
      hour_keys.each do |hour_key|
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
      db.hash_keys(hours_set_key)
    end

    def hours_set_key
      "#{key}::hours"
    end

    def key_for_hour(time)
      "#{key}::#{ time.strftime("%Y%m%d%H") }"
    end

  end
end
