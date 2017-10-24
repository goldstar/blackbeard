module Blackbeard
  module DashboardRoutes
    class Revisions < Base
      get '/revisions' do
        @revisions = Revision.all
        erb 'revisions/index'.to_sym
      end

      get '/revisions/:id' do
        ensure_revision; ensure_charts
        erb 'revisions/show'.to_sym
      end

      def ensure_revision
        @revision = Revision.find(params[:id]) or pass
      end

      def ensure_charts
        @charts = [@revision.recent_hours_chart, @revision.recent_days_chart]
      end
    end
  end
end
