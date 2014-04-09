module Blackbeard
  module DashboardRoutes
    class Features < Base

      get '/features' do
        @features = Feature.all
        erb 'features/index'.to_sym
      end

      get "/features/:id" do
        ensure_feature; find_metric
        @groups = Group.all
        erb 'features/show'.to_sym
      end

      post "/features/:id" do
        ensure_feature.update_attributes(params)
        "OK"
      end

      post "/features/:id/metrics" do
        ensure_feature; find_metric
        @feature.add_metric(@metric) if @metric
        redirect url("features/#{@feature.id}?metric_type=#{@metric.type}&metric_type_id=#{@metric.type_id}")
      end

      post "/features/:id/groups/:group_id" do
        ensure_feature
        @feature.set_group_segments_for(params[:group_id], params[:segments])
        @feature.save
        "OK"
      end

      def find_metric
        @metric = Metric.find(params[:metric_type], params[:metric_type_id]) if params[:metric_type]
      end

      def ensure_feature
        @feature = Feature.find(params[:id]) or pass
      end

    end
  end
end
