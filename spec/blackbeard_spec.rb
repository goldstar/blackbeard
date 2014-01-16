require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard do
  it "should not sink" do
    Blackbeard.should_not be_nil
  end
end
