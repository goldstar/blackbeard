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

    get '/metrics' do
      @metrics = Blackbeard::Metric.all
      erb 'metrics/index'.to_sym
    end

    get "/metrics/:type/:id" do
      @metric = Blackbeard::Metric.new_from_type_id(params[:type], params[:id])
      erb 'metrics/show'.to_sym
    end

    post "/metrics/:type/:id" do
      @metric = Blackbeard::Metric.new_from_type_id(params[:type], params[:id])
      @metric.update_attributes(params)
      "OK"
    end

    get '/tests' do
      @tests = Blackbeard::Test.all
      erb 'tests/index'.to_sym
    end

    get "/tests/:id" do
      @test = Blackbeard::Test.new(params[:id])
      erb 'tests/show'.to_sym
    end

  end
end
