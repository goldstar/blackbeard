module Blackbeard
  module DashboardRoutes
    class Home < Base

      get '/' do
        erb :index
      end

    end
  end
end
