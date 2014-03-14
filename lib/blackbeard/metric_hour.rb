module Blackbeard
  class MetricHour
    attr_reader :hour, :result

    def initialize(time, result)
      @hour = round_to_beginning_of_hour(time)
      @result = result
    end

    def results_for(segments)
      segments.map{|s| result[s].to_f }
    end

    def result_rows(segments)
      [@hour.strftime("%l%P")] + results_for(segments)
    end

  private

    def round_to_beginning_of_hour(t)
      t - ((t.min * 60) + t.sec)
    end

  end
end
