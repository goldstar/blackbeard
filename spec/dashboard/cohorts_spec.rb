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

        expect(last_response).to be_ok
        expect(last_response.body).to include('cohorts')
      end
    end

    describe "get /cohorts/:id" do
      it "should show a metric" do
        cohort = Cohort.create("jostling")
        get "/cohorts/#{cohort.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include("jostling")
      end
    end

    describe "post /cohorts/:id" do
      it "should update the cohort" do
        cohort = Cohort.create("jostling")
        post "/cohorts/#{cohort.id}", :name => 'hello'

        expect(last_response).to be_ok
        expect(Cohort.find("jostling").name).to eq('hello')
      end
    end

  end
end
