module Blackbeard
  module DashboardRoutes
    class Groups < Base
      get '/groups' do
        @groups = Group.all
        erb 'groups/index'.to_sym
      end

      get '/groups/:id' do
        ensure_group
        erb 'groups/show'.to_sym
      end

      post "/groups/:id" do
        ensure_group.update_attributes(params)
        "OK"
      end

      def ensure_group
        @group = Group.find(params[:id]) or pass
      end

    end
  end
end
