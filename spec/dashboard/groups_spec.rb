require File.expand_path(File.dirname(__FILE__) + './../spec_helper')

require 'rack/test'
require 'blackbeard/dashboard'

module Blackbeard
  describe Dashboard do
    include Rack::Test::Methods

    let(:app) { Dashboard }

    describe "get /groups" do
      it "should list all the groups" do
        Group.create("jostling")
        get "/groups"

        expect(last_response).to be_ok
        expect(last_response.body).to include('jostling')
      end
    end

    describe "get /groups/:id" do
      it "should show a metric" do
        group = Group.create("jostling")
        get "/groups/#{group.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include("jostling")
      end
    end

    describe "post /groups/:id" do
      it "should update the group" do
        group = Group.create("jostling")
        post "/groups/#{group.id}", :name => 'hello'

        expect(last_response).to be_ok
        expect(Group.find("jostling").name).to eq('hello')
      end
    end

  end
end
