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
      [js_date(d.date)] + _js_metric_date_results(segments, d.result)
    end

    def js_metric_hour(segments, h)
      row = [js_hour(h.hour)] + _js_metric_date_results(segments, h.result)
    end

    def _js_metric_date_results(segments, result)
      segments.each{|s| row.push result[s].to_f }
      "[" + row.join(',') + "]"
    end
  end
end

