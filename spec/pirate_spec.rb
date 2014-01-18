require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Pirate do
  let(:pirate) { Blackbeard::Pirate.new }

  describe "memoization" do
    let(:name){ "bond" }

    it "should get features once" do
      Blackbeard::Feature.should_receive(:new).with(name).once.and_return(true)
      4.times{ pirate.feature(name) }
    end

    it "should get unique metrics once" do
      Blackbeard::Metric::Unique.should_receive(:new).with(name).once.and_return(true)
      4.times{ pirate.unique_metric(name) }
    end

    it "should get total metrics once" do
      Blackbeard::Metric::Total.should_receive(:new).with(name).once.and_return(true)
      4.times{ pirate.total_metric(name) }
    end

  end

end
