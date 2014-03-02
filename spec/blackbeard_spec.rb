require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard do
  it "should not sink" do
    Blackbeard.should_not be_nil
  end

  describe "pirate" do
    it "can configure" do
      p = Blackbeard.pirate do |config|
        config.timezone = 'America/Somewhere'
      end
      Blackbeard.config.timezone.should == 'America/Somewhere'
    end
    it "returns a pirate" do
        Blackbeard.pirate.should be_a(Blackbeard::Pirate)
    end
  end

end
