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

  end
end

