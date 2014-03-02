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

        last_response.should be_ok
        last_response.body.should include('jostling')
      end
    end

    describe "get /features/:id" do
      it "should show a feature" do
        feature = Feature.create("jostling")
        get "/features/#{feature.id}"

        last_response.should be_ok
        last_response.body.should include("jostling")
      end
    end

    describe "post /features/:id" do
      it "should update the feature" do
        feature = Feature.create("jostling")
        post "/features/#{feature.id}", :name => 'hello'

        last_response.should be_ok
        feature.reload.name.should == 'hello'
      end
    end

  end
end
