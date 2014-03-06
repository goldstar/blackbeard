require File.expand_path(File.dirname(__FILE__) + './../spec_helper')

require 'rack/test'
require 'blackbeard/dashboard'

module Blackbeard
  describe Dashboard do
    include Rack::Test::Methods

    let(:app) { Dashboard }

    describe "get /cohorts" do
      it "should list all the groups" do
        Cohort.create("jostling")
        get "/cohorts"

        last_response.should be_ok
        last_response.body.should include('cohorts')
      end
    end

    describe "get /cohorts/:id" do
      it "should show a metric" do
        cohort = Cohort.create("jostling")
        get "/cohorts/#{cohort.id}"

        last_response.should be_ok
        last_response.body.should include("jostling")
      end
    end

    describe "post /cohorts/:id" do
      it "should update the cohort" do
        cohort = Cohort.create("jostling")
        post "/cohorts/#{cohort.id}", :name => 'hello'

        last_response.should be_ok
        Cohort.find("jostling").name.should == 'hello'
      end
    end

  end
end
