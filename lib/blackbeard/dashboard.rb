$LOAD_PATH << File.expand_path('../../../dashboard', __FILE__)

require 'sinatra/base'
require 'blackbeard'
require 'blackbeard/dashboard_helpers'
require 'routes/base'
require 'routes/home'
require 'routes/groups'
require 'routes/metrics'
require 'routes/tests'
require 'routes/features'
require 'routes/cohorts'

module Blackbeard
  class Dashboard < Sinatra::Base
    configure do
      set :public_folder, Proc.new { "#{root}/public" }
    end

    use DashboardRoutes::Home
    use DashboardRoutes::Metrics
    use DashboardRoutes::Tests
    use DashboardRoutes::Groups
    use DashboardRoutes::Features
    use DashboardRoutes::Cohorts
  end
end
