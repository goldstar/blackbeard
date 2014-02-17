module Blackbeard
  module DashboardRoutes
    class Metrics < Base

      get '/metrics' do
        @metrics = Metric.all
        erb 'metrics/index'.to_sym
      end

      get "/metrics/:type/:type_id" do
        @metric = Metric.new(params[:type], params[:type_id])
        erb 'metrics/show'.to_sym
      end

      post "/metrics/:type/:type_id" do
        @metric = Metric.new(params[:type], params[:type_id])
        @metric.update_attributes(params)
        "OK"
      end

    end
  end
end
