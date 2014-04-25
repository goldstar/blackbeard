module Blackbeard
  module DashboardRoutes
    class Home < Base

      get '/' do
        @changes = Change.last(20)
        erb :index
      end

    end
  end
end
