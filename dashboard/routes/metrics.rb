module Blackbeard
  module DashboardRoutes
    class Metrics < Base
      get '/metrics' do
        @metrics = Metric.all
        erb 'metrics/index'.to_sym
      end

      get "/metrics/:type/:type_id" do
        ensure_metric; find_group; find_cohort; ensure_charts
        erb 'metrics/show'.to_sym
      end

      post "/metrics/:type/:type_id" do
        ensure_metric
        @metric.update_attributes(params)
        "OK"
      end

      post "/metrics/:type/:type_id/groups" do
        ensure_metric; find_group
        @metric.add_group(@group) if @group
        redirect url("metrics/#{@metric.type}/#{@metric.type_id}?group_id=#{@group.id}")
      end

      post "/metrics/:type/:type_id/cohorts" do
        ensure_metric; find_cohort
        @metric.add_cohort(@cohort) if @cohort
        redirect url("metrics/#{@metric.type}/#{@metric.type_id}?cohort_id=#{@cohort.id}")
      end

      def ensure_metric
        @metric = Metric.find(params[:type], params[:type_id]) or pass
      end

      def find_group
        @group = Group.find(params[:group_id]) if params[:group_id]
      end

      def find_cohort
        @cohort = Cohort.find(params[:cohort_id]) if params[:cohort_id]
      end

      def ensure_charts
        @charts = []
      end

    end
  end
end
