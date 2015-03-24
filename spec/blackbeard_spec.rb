require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard do
  it "should not sink" do
    expect(Blackbeard).not_to be_nil
  end

  describe "pirate" do
    it "can configure" do
      p = Blackbeard.pirate do |config|
        config.timezone = 'America/Somewhere'
      end
      expect(Blackbeard.config.timezone).to eq('America/Somewhere')
    end
    it "returns a pirate" do
        expect(Blackbeard.pirate).to be_a(Blackbeard::Pirate)
    end
  end

end
