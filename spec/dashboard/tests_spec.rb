require File.expand_path(File.dirname(__FILE__) + './../spec_helper')

require 'rack/test'
require 'blackbeard/dashboard'

module Blackbeard
  describe Dashboard do
    include Rack::Test::Methods

    let(:app) { Dashboard }

    describe "get /tests" do
      it "should list all the test" do
        Test.new("jostling")
        get "/tests"

        last_response.should be_ok
        last_response.body.should include('jostling')
      end
    end

    describe "get /tests/:id" do
      it "should show a test" do
        test = Test.new("jostling")
        get "/tests/#{test.id}"

        last_response.should be_ok
        last_response.body.should include("jostling")
      end
    end

    describe "post /tests/:id" do
      it "should update the test" do
        test = Test.new("jostling")
        post "/tests/#{test.id}", :name => 'hello'

        last_response.should be_ok
        Test.new("jostling").name.should == 'hello'
      end
    end

  end
end
