module Blackbeard
  module DashboardHelpers
    def url(path = '')
      env['SCRIPT_NAME'].to_s + '/' + path
    end

    def metric_data(metric, group_or_cohort)
      if group_or_cohort.nil?
        metric.metric_data
      else
        group_or_cohort.metric_data(metric)
      end
    end

  end
end
