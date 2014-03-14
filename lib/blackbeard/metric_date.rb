module Blackbeard
  class MetricDate
    #TODO refactor with MetricHour to be compaosed
    attr_reader :date, :result

    def initialize(date, result)
      @date = date
      @result = result
    end

    def results_for(segments)
      segments.map{|s| result[s].to_f }
    end

    def result_rows(segments)
      [@date.to_s] + results_for(segments)
    end


  end
end
