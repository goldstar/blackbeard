module Blackbeard
  module Chartable

    # In your class define 3 methods:
    #   * chartable_segments
    #   * chartable_result_for_hour
    #   * chartable_result_for_day

    def recent_days(count=28, starting_on = tz.now.to_date)
      Array(0..count-1).map do |offset|
        date = starting_on - offset
        result = chartable_result_for_day(date)
        Blackbeard::MetricDate.new(date, result)
      end
    end

    def recent_hours(count = 24, starting_at = tz.now)
      Array(0..count-1).map do |offset|
        hour = starting_at - (offset * 3600)
        result = chartable_result_for_hour(hour)
        Blackbeard::MetricHour.new(hour, result)
      end
    end

    def recent_hours_chart(count = 24, starting_at = tz.now)
      data = recent_hours(count, starting_at)
      title = "Last #{count} Hours"
      Chart.new(
        :dom_id => 'recent_hour_chart',
        :title => title,
        :columns => ['Hour']+chartable_segments,
        :rows => data.reverse.map{ |metric_hour| metric_hour.result_rows(chartable_segments) }
      )
    end

    def recent_days_chart(count = 28, starting_on = tz.now.to_date)
      data = recent_days(count, starting_on)
      Chart.new(
        :dom_id => 'recent_days_chart',
        :title => "Last #{count} Days",
        :columns => ['Day']+chartable_segments,
        :rows => data.reverse.map{ |metric_date| metric_date.result_rows(chartable_segments) }
      )
    end

  end
end
