module Blackbeard
  module DashboardHelpers
    def url(path = '')
      env['SCRIPT_NAME'].to_s + '/' + path
    end

    def js_date(date)
      "new Date(#{ date.year }, #{ date.month - 1}, #{ date.day } )"
    end

    def js_hour(hour)
      "new Date(#{ hour.year}, #{hour.month - 1 }, #{hour.day}, #{hour.hour})"
    end

    def js_metric_date(segments, d)
      row = [js_date(d.date)]
      segments.each{|s| row.push d.result[s].to_f }
      "[" + row.join(',') + "]"
    end

    def js_metric_hour(segments, h)
      row = [js_hour(h.hour)]
      segments.each{|s| row.push h.result[s].to_f }
      "[" + row.join(',') + "]"
    end

    def metric_data(metric, group_or_cohort)
      if group_or_cohort.nil?
        metric.metric_data
      else
        group_or_chort.metric_data(metric)
      end
    end

  end
end
