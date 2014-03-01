require File.expand_path(File.dirname(__FILE__) + './../spec_helper')

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
        Group.create("jostling")
        get "/groups"

        last_response.should be_ok
        last_response.body.should include('jostling')
      end
    end

    describe "get /groups/:id" do
      it "should show a metric" do
        group = Group.create("jostling")
        get "/groups/#{group.id}"

        last_response.should be_ok
        last_response.body.should include("jostling")
      end
    end

    describe "post /groups/:id" do
      it "should update the group" do
        group = Group.create("jostling")
        post "/groups/#{group.id}", :name => 'hello'

        last_response.should be_ok
        Group.find("jostling").name.should == 'hello'
      end
    end

  end
end
