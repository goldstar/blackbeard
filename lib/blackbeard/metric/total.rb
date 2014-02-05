require "blackbeard/metric"
require "date"

module Blackbeard
  class Metric::Total < Metric

    def add(uid, amount)
      key = key_for_hour(tz.now)
      db.set_add_member(hours_set_key, key)
      db.increment_by_float(key, amount.to_f)
    end

    def result_for_hour(time)
      key = key_for_hour(time)
      db.get(key).to_f
    end

    def result_for_day(date)
      key = key_for_date(date)
      result = db.get(key) || generate_result_for_day(date)
      result.to_f
    end

  private

    def merge_results(keys)
      db.multi_get(keys).map(&:to_f).inject(:+) # .sum
    end

  end
end
