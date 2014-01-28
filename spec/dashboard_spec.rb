require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rack/test'
require 'blackbeard/dashboard'

describe Blackbeard::Dashboard do
  include Rack::Test::Methods

  let(:app) { Blackbeard::Dashboard }

  describe "/" do
    it "should redirect" do
      get "/"
      last_response.should be_ok
    end
  end

  describe "/metrics" do
    it "should list all the metrics" do
      Blackbeard::Metric::Total.new("jostling")
      get "/metrics"

      last_response.should be_ok
      last_response.body.should include('jostling')
    end
  end

  describe "/metrics/:type/:id" do
    it "should show a metric" do
      metric = Blackbeard::Metric::Total.new("jostling")
      get "/metrics/#{metric.type}/#{metric.id}"

      last_response.should be_ok
      last_response.body.should include("jostling")
    end
  end

end
