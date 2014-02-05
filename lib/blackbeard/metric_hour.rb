module Blackbeard
  class MetricHour
    attr_reader :hour, :result

    def initialize(time, result)
      @hour = round_to_beginning_of_hour(time)
      @result = result
    end

    def hour_array
      hour.to_a.first(6).reverse
    end

  private

    def round_to_beginning_of_hour(t)
      t - ((t.min * 60) + t.sec)
    end

  end
end
