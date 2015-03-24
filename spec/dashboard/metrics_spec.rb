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

        expect(last_response).to be_ok
        expect(last_response.body).to include('jostling')
      end
    end

    describe "get /metrics/:type/:type_id" do
      it "should show a metric" do
        metric = Metric.create("total", "jostling")
        get "/metrics/#{metric.type}/#{metric.type_id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include("jostling")
      end

      it "should show a metric with a group" do
        metric = Metric.create("total", "jostling")
        group = Group.create(:example)
        metric.add_group(group)
        get "/metrics/#{metric.type}/#{metric.type_id}", :group_id => group.id

        expect(last_response).to be_ok
        expect(last_response.body).to include("jostling")
      end

      it "should show a metric with a cohort" do
        metric = Metric.create("total", "jostling")
        cohort = Cohort.create(:example)
        metric.add_cohort(cohort)
        get "/metrics/#{metric.type}/#{metric.type_id}", :cohort_id => cohort.id

        expect(last_response).to be_ok
        expect(last_response.body).to include("jostling")
      end

    end

    describe "post /metrics/:type/:type_id" do
      it "should update the metric" do
        metric = Metric.create("total", "jostling")
        post "/metrics/#{metric.type}/#{metric.type_id}", :name => 'hello'

        expect(last_response).to be_ok
        expect(Metric.find(:total, "jostling").name).to eq('hello')
      end
    end

    describe "post /metrics/:type/:type_id/groups" do
      it "should add a group to the metric" do
        metric = Metric.create("total", "jostling")
        group = Group.create("admin")
        post "/metrics/#{metric.type}/#{metric.type_id}/groups", :group_id => group.id

        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to eq("http://example.org/metrics/#{metric.type}/#{metric.type_id}?group_id=#{group.id}")
        expect(metric.has_group?(group)).to be_truthy
      end
    end


    describe "post /metrics/:type/:type_id/cohorts" do
      it "should add a cohort to the metric" do
        metric = Metric.create("total", "jostling")
        cohort = Cohort.create("admin")
        post "/metrics/#{metric.type}/#{metric.type_id}/cohorts", :cohort_id => cohort.id

        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to eq("http://example.org/metrics/#{metric.type}/#{metric.type_id}?cohort_id=#{cohort.id}")
        expect(metric.has_cohort?(cohort)).to be_truthy
      end
    end


  end
end
