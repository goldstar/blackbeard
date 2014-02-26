require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Feature do
  let(:feature){ Blackbeard::Feature.new('example') }

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
