module Blackbeard
  module DashboardRoutes
    class Cohorts < Base
      get '/cohorts' do
        @cohorts = Cohort.all
        erb 'cohorts/index'.to_sym
      end

      get '/cohorts/:id' do
        @cohort = Cohort.find(params[:id]) or pass
        erb 'cohorts/show'.to_sym
      end

      post "/cohorts/:id" do
        @cohort = Cohort.find(params[:id]) or pass
        @cohort.update_attributes(params)
        "OK"
      end

    end
  end
end
