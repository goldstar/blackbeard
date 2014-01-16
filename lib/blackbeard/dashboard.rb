require 'sinatra/base'
require 'blackbeard'
require 'blackbeard/dashboard/helpers'

module Blackbeard
  class Dashboard < Sinatra::Base
    set :root, File.expand_path(File.dirname(__FILE__) + "/dashboard")
    set :public_folder, Proc.new { "#{root}/public" }
    set :views, Proc.new { "#{root}/views" }
    set :raise_errors, true
    set :show_exceptions, false

    helpers Blackbeard::DashboardHelpers

    get '/' do
      redirect url('/metrics')
    end

    get '/metrics' do
      @metrics = Blackbeard::Metric.all
      erb 'metrics/index'.to_sym
    end

    get "/metrics/:type/:name" do
      @metric = Blackbeard::Metric.new_from_type_name(params[:type], params[:name])
      erb 'metrics/show'.to_sym
    end

  end
end
