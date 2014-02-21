require 'sinatra/partial'

module Blackbeard
  module DashboardRoutes
    class Base < Sinatra::Application
      register Sinatra::Partial

      set :root, File.expand_path(File.dirname(__FILE__) + "./..")
      set :views, Proc.new { "#{root}/views" }
      set :raise_errors, true
      set :show_exceptions, false
      set :partial_template_engine, :erb
      enable :partial_underscores
      # set :erb, :escape_html => true

      helpers Blackbeard::DashboardHelpers
    end
  end
end
