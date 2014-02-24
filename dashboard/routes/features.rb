module Blackbeard
  module DashboardRoutes
    class Features < Base

      get '/features' do
        @features = Feature.all
        erb 'features/index'.to_sym
      end

      get "/features/:id" do
        @feature = Feature.new(params[:id])
        erb 'features/show'.to_sym
      end

      post "/features/:id" do
        @feature = Feature.new(params[:id])
        @feature.update_attributes(params)
        "OK"
      end

    end
  end
end
