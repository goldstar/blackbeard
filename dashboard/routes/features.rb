module Blackbeard
  module DashboardRoutes
    class Features < Base

      get '/features' do
        @features = Feature.all
        erb 'features/index'.to_sym
      end

      get "/features/:id" do
        @feature = Feature.find(params[:id]) or pass
        @groups = Group.all
        erb 'features/show'.to_sym
      end

      post "/features/:id" do
        @feature = Feature.find(params[:id]) or pass
        @feature.update_attributes(params)
        "OK"
      end

      post "/features/:id/groups/:group_id" do
        @feature = Feature.find(params[:id]) or pass
        @feature.set_segments_for(params[:group_id], params[:segments])
        @feature.save
        "OK"
      end

    end
  end
end
