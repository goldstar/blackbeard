require 'sinatra/base'
require 'blackbeard'
require 'blackbeard/dashboard_helpers'

module Blackbeard
  class Dashboard < Sinatra::Base
    set :root, File.expand_path(File.dirname(__FILE__) + "./../../dashboard")
    set :public_folder, Proc.new { "#{root}/public" }
    set :views, Proc.new { "#{root}/views" }
    set :raise_errors, true
    set :show_exceptions, false

    helpers Blackbeard::DashboardHelpers

    get '/' do
      erb :index
    end

    get '/groups' do
      @groups = Group.all
      erb 'groups/index'.to_sym
    end

    get '/groups/:id' do
      @group = Group.new(params[:id])
      erb 'groups/show'.to_sym
    end

    post "/groups/:id" do
      @group = Group.new(params[:id])
      @group.update_attributes(params)
      "OK"
    end

    get '/metrics' do
      @metrics = Metric.all
      erb 'metrics/index'.to_sym
    end

    get "/metrics/:type/:type_id" do
      @metric = Metric.new(params[:type], params[:type_id])
      erb 'metrics/show'.to_sym
    end

    post "/metrics/:type/:type_id" do
      @metric = Metric.new(params[:type], params[:type_id])
      @metric.update_attributes(params)
      "OK"
    end

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
