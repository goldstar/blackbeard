module Blackbeard
  module DashboardRoutes
    class Cohorts < Base
      get '/cohorts' do
        @cohorts = Cohort.all
        erb 'cohorts/index'.to_sym
      end

      get '/cohorts/:id' do
        ensure_cohort
        erb 'cohorts/show'.to_sym
      end

      post "/cohorts/:id" do
        ensure_cohort.update_attributes(params)
        "OK"
      end

      def ensure_cohort
        @cohort = Cohort.find(params[:id]) or pass
      end

    end
  end
end
