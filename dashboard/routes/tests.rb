module Blackbeard
  module DashboardRoutes
    class Tests < Base

      get '/tests' do
        @tests = Test.all
        erb 'tests/index'.to_sym
      end

      get "/tests/:id" do
        @test = Test.new(params[:id])
        erb 'tests/show'.to_sym
      end

      post "/tests/:id" do
        @test = Test.new(params[:id])
        @test.update_attributes(params)
        "OK"
      end

    end
  end
end
