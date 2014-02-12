require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rack/test'
require 'blackbeard/dashboard'

describe Blackbeard::Dashboard do
  include Rack::Test::Methods

  let(:app) { Blackbeard::Dashboard }

  describe "get /" do
    it "should redirect" do
      get "/"
      last_response.should be_ok
    end
  end

  describe "get /groups" do
    it "should list all the groups" do
      Blackbeard::Group.new("jostling")
      get "/groups"

      last_response.should be_ok
      last_response.body.should include('jostling')
    end
  end

  describe "get /groups/:id" do
    it "should show a metric" do
      group = Blackbeard::Group.new("jostling")
      get "/groups/#{group.id}"

      last_response.should be_ok
      last_response.body.should include("jostling")
    end
  end

  describe "get /metrics" do
    it "should list all the metrics" do
      Blackbeard::Metric::Total.new("jostling")
      get "/metrics"

      last_response.should be_ok
      last_response.body.should include('jostling')
    end
  end

  describe "get /metrics/:type/:id" do
    it "should show a metric" do
      metric = Blackbeard::Metric::Total.new("jostling")
      get "/metrics/#{metric.type}/#{metric.id}"

      last_response.should be_ok
      last_response.body.should include("jostling")
    end
  end

  describe "post /metrics/:type/:id" do
    it "should update the metric" do
      metric = Blackbeard::Metric::Total.new("jostling")
      post "/metrics/#{metric.type}/#{metric.id}", :name => 'hello'

      last_response.should be_ok
      reloaded_metric = Blackbeard::Metric::Total.new("jostling").name.should == 'hello'
    end
  end

end
