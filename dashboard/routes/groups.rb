module Blackbeard
  module DashboardRoutes
    class Groups < Base
      get '/groups' do
        @groups = Group.all
        erb 'groups/index'.to_sym
      end

      get '/groups/:id' do
        @group = Group.find(params[:id]) or pass
        erb 'groups/show'.to_sym
      end

      post "/groups/:id" do
        @group = Group.find(params[:id]) or pass
        @group.update_attributes(params)
        "OK"
      end

    end
  end
end
