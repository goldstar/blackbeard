module Blackbeard
  class MetricDate
    attr_reader :date, :result

    def initialize(date, result)
      @date = date
      @result = result
    end

  end
end
