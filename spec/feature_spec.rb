require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Feature do
  let(:feature){ Blackbeard::Feature.create('example') }

  describe "segments_for and set_segments_for" do
    it "should return an empty list if no segments" do
      feature.segments_for(:nothing).should == []
    end

    it "should return the segments for the group" do
      feature.set_segments_for(:hello, ["world", "goodbye"])
      feature.set_segments_for(:foo, "bar")
      feature.segments_for(:hello).should include("world","goodbye")
      feature.segments_for(:hello).should_not include("bar")
      feature.segments_for(:foo).should == ["bar"]
    end
  end

  describe "#active_for?" do
    let(:context){ double }

    context "when status is nil" do
      it "should be false" do
        feature.active_for?(context).should be_false
      end
    end

    context "when status is inactive" do
      it "should be false" do
        feature.status = :inactive
        feature.active_for?(context).should be_false
      end
    end

    context "when status is active" do
      it "should be true" do
        feature.status = :active
        feature.active_for?(context).should be_true
      end
    end
  end


end
