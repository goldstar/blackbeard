module Blackbeard
  module DashboardRoutes
    class Features < Base

      get '/features' do
        @features = Feature.all
        erb 'features/index'.to_sym
      end

      get "/features/:id" do
        ensure_feature
        @groups = Group.all
        erb 'features/show'.to_sym
      end

      post "/features/:id" do
        ensure_feature.update_attributes(params)
        "OK"
      end

      post "/features/:id/groups/:group_id" do
        ensure_feature
        @feature.set_group_segments_for(params[:group_id], params[:segments])
        @feature.save
        "OK"
      end

      def ensure_feature
        @feature = Feature.find(params[:id]) or pass
      end

    end
  end
end
