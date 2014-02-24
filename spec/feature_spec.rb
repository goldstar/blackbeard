require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Feature do
  let(:feature){ Blackbeard::Feature.new('example') }

  describe "#active?" do
    it "should be false" do
      feature.should_not be_active
    end
  end
end
