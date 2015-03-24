require File.expand_path(File.dirname(__FILE__) + './../spec_helper')

require 'rack/test'
require 'blackbeard/dashboard'

module Blackbeard
  describe Dashboard do
    include Rack::Test::Methods

    let(:app) { Dashboard }

    describe "get /features" do
      it "should list all the features" do
        Feature.create("jostling")
        get "/features"

        expect(last_response).to be_ok
        expect(last_response.body).to include('jostling')
      end
    end

    describe "get /features/:id" do
      it "should show a feature" do
        feature = Feature.create("jostling")
        get "/features/#{feature.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include("jostling")
      end
    end

    describe "post /features/:id" do
      it "should update the feature" do
        feature = Feature.create("jostling")
        post "/features/#{feature.id}", :name => 'hello'

        expect(last_response).to be_ok
        expect(feature.reload.name).to eq('hello')
      end
    end

    describe "post /features/:id/groups/:group_id" do
      it "should update the features segments" do
        feature = Feature.create("jostling")
        post "/features/#{feature.id}/groups/hello", :segments => ["world","goodbye"]

        expect(last_response).to be_ok
        expect(feature.reload.group_segments_for(:hello)).to include("world", "goodbye")
      end
    end

    describe "post /features/:id/metrics" do
      it "should add a metric to the feature" do
        feature = Feature.create("jostling")
        metric = Metric.create("total", "jostling")
        post "/features/#{feature.id}/metrics", :metric_type => metric.type, :metric_type_id => metric.type_id

        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to eq("http://example.org/features/#{feature.id}?metric_type=#{metric.type}&metric_type_id=#{metric.type_id}")
        expect(feature.has_metric?(metric)).to be_truthy
      end
    end

  end
end
