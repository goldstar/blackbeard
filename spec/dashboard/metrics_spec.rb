require File.expand_path(File.dirname(__FILE__) + './../spec_helper')

require 'rack/test'
require 'blackbeard/dashboard'

module Blackbeard
  describe Dashboard do
    include Rack::Test::Methods

    let(:app) { Dashboard }

    describe "get /metrics" do
      it "should list all the metrics" do
        Metric.create("total", "jostling")
        get "/metrics"

        last_response.should be_ok
        last_response.body.should include('jostling')
      end
    end

    describe "get /metrics/:type/:type_id" do
      it "should show a metric" do
        metric = Metric.create("total", "jostling")
        get "/metrics/#{metric.type}/#{metric.type_id}"

        last_response.should be_ok
        last_response.body.should include("jostling")
      end
    end

    describe "post /metrics/:type/:type_id" do
      it "should update the metric" do
        metric = Metric.create("total", "jostling")
        post "/metrics/#{metric.type}/#{metric.type_id}", :name => 'hello'

        last_response.should be_ok
        Metric.find(:total, "jostling").name.should == 'hello'
      end
    end

    describe "post /metrics/:type/:type_id/groups" do
      it "should add a group to the metric" do
        metric = Metric.create("total", "jostling")
        group = Group.create("admin")
        post "/metrics/#{metric.type}/#{metric.type_id}/groups", :group_id => group.id

        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == "http://example.org/metrics/#{metric.type}/#{metric.type_id}?group_id=#{group.id}"
        metric.has_group?(group).should be_true
      end
    end


  end
end
