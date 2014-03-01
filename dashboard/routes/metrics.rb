module Blackbeard
  module DashboardRoutes
    class Metrics < Base
      get '/metrics' do
        @metrics = Metric.all
        erb 'metrics/index'.to_sym
      end

      get "/metrics/:type/:type_id" do
        @metric = Metric.find(params[:type], params[:type_id])
        @group = Group.find(params[:group_id]) if params[:group_id]
        erb 'metrics/show'.to_sym
      end

      post "/metrics/:type/:type_id" do
        @metric = Metric.find(params[:type], params[:type_id])
        @metric.update_attributes(params)
        "OK"
      end

      post "/metrics/:type/:type_id/groups" do
        @metric = Metric.find(params[:type], params[:type_id])
        @group = Group.find(params[:group_id])
        @metric.add_group(@group)
        redirect url("metrics/#{@metric.type}/#{@metric.type_id}?group_id=#{@group.id}")
      end

    end
  end
end
