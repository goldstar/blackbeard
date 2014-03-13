module Blackbeard
  module DashboardRoutes
    class Tests < Base

      get '/tests' do
        @tests = Test.all
        erb 'tests/index'.to_sym
      end

      get "/tests/:id" do
        ensure_test
        erb 'tests/show'.to_sym
      end

      post "/tests/:id" do
        ensure_test.update_attributes(params)
        "OK"
      end

      def ensure_test
        @test = Test.find(params[:id]) or pass
      end

    end
  end
end
