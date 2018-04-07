require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard do
  it "should not sink" do
    expect(Blackbeard).not_to be_nil
  end

  describe "pirate" do
    it 'is memoized within the same thread' do
      expect(Blackbeard.pirate).to equal(Blackbeard.pirate)
    end

    it 'is unique across threads' do
      expect(Blackbeard.pirate).to_not equal(Thread.new{Blackbeard.pirate}.value)
    end
  end

  describe '#configure!' do
    after { Blackbeard.configure! {} }

    it "sets the values as expected" do
      Blackbeard.configure! do |config|
        config.timezone = 'America/Somewhere'
      end

      expect(Blackbeard.config.timezone).to eq('America/Somewhere')
    end
  end

end
