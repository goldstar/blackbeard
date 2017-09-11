require File.expand_path(File.dirname(__FILE__) + './../spec_helper')

require 'rack/test'
require 'blackbeard/dashboard'

module Blackbeard
  describe Dashboard do
    include Rack::Test::Methods

    let(:app) { Dashboard }

    describe "get /revisions" do
      it "should list all the groups" do
        Revision.create('20170912')
        get "/revisions"

        expect(last_response).to be_ok
        expect(last_response.body).to include('revisions')
      end
    end

    describe "get /revisions/:id" do
      it "should show a metric" do
        revision = Revision.create("20170912")
        get "/revisions/#{revision.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include("20170912")
      end
    end
  end
end
