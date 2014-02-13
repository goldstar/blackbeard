require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rack/test'
require 'blackbeard/dashboard'

module Blackbeard
  describe Dashboard do
    include Rack::Test::Methods

    let(:app) { Dashboard }

    describe "get /" do
      it "should redirect" do
        get "/"
        last_response.should be_ok
      end
    end

    describe "get /groups" do
      it "should list all the groups" do
        Group.new("jostling")
        get "/groups"

        last_response.should be_ok
        last_response.body.should include('jostling')
      end
    end

    describe "get /groups/:id" do
      it "should show a metric" do
        group = Group.new("jostling")
        get "/groups/#{group.id}"

        last_response.should be_ok
        last_response.body.should include("jostling")
      end
    end

    describe "get /metrics" do
      it "should list all the metrics" do
        Metric.new("total", "jostling")
        get "/metrics"

        last_response.should be_ok
        last_response.body.should include('jostling')
      end
    end

    describe "get /metrics/:type/:id" do
      it "should show a metric" do
        metric = Metric.new("total", "jostling")
        get "/metrics/#{metric.type}/#{metric.id}"

        last_response.should be_ok
        last_response.body.should include("jostling")
      end
    end

    describe "post /metrics/:type/:id" do
      it "should update the metric" do
        metric = Metric.new("total", "jostling")
        post "/metrics/#{metric.type}/#{metric.type_id}", :name => 'hello'

        last_response.should be_ok
        reloaded_metric = Metric.new(:total, "jostling").name.should == 'hello'
      end
    end

  end
end
