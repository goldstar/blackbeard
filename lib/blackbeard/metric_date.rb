module Blackbeard
  class MetricDate
    attr_reader :date, :result

    def initialize(date, result)
      @date = date
      @result = result
    end

    def date_array
      [date.year, date.month, date.day]
    end

  end
end
