require File.expand_path(File.dirname(__FILE__) + './../spec_helper')

require 'rack/test'
require 'blackbeard/dashboard'

module Blackbeard
  describe Dashboard do
    include Rack::Test::Methods

    let(:app) { Dashboard }

    describe "get /tests" do
      it "should list all the test" do
        Test.create("jostling")
        get "/tests"

        expect(last_response).to be_ok
        expect(last_response.body).to include('jostling')
      end
    end

    describe "get /tests/:id" do
      it "should show a test" do
        test = Test.create("jostling")
        get "/tests/#{test.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include("jostling")
      end
    end

    describe "post /tests/:id" do
      it "should update the test" do
        test = Test.create("jostling")
        post "/tests/#{test.id}", :name => 'hello'

        expect(last_response).to be_ok
        expect(test.reload.name).to eq('hello')
      end
    end

  end
end
