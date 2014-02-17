module Blackbeard
  module DashboardRoutes
    class Base < Sinatra::Application
      set :root, File.expand_path(File.dirname(__FILE__) + "./..")
      set :views, Proc.new { "#{root}/views" }
      set :raise_errors, true
      set :show_exceptions, false
      # set :erb, :escape_html => true

      helpers Blackbeard::DashboardHelpers
    end
  end
end
