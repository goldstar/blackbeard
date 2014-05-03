module Blackbeard
  module DashboardHelpers
    def url(path = '')
      env['SCRIPT_NAME'].to_s + '/' + path
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
end
