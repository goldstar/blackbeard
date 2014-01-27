module Blackbeard
  module DashboardHelpers
    def url(path = '')
      env['SCRIPT_NAME'].to_s + '/' + path
    end
  end
end

