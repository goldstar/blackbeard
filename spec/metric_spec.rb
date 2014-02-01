require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Metric do

  describe "hour_keys" do
    before :each do
      @total_metric = Blackbeard::Metric::Total.new("one-total")
    end

    it "should return an empty array if no metrics" do
      @total_metric.send(:hour_keys).should == []
    end

    it "should return an array for each hour" do
      @total_metric.add('user1', 1)
      key = @total_metric.send(:key_for_hour, Blackbeard.tz.now)
      @total_metric.send(:hour_keys).should == [key]
    end
  end

  describe "recent_hours" do
    let(:metric) { Blackbeard::Metric::Total.new("one-total") }
    let(:start_at) { Time.new(2014,1,1,12,0,0) }

    it "should return results for recent hours" do
      metric.recent_hours(3, start_at).should == [
        {:hour => '2014010112', :result => 0 },
        {:hour => '2014010111', :result => 0 },
        {:hour => '2014010110', :result => 0 }
      ]
    end
  end

  describe "hours" do
    before :each do
      @total_metric = Blackbeard::Metric::Total.new("one-total")
    end

    it "should return an array of hashes" do
      @total_metric.add('user1', 1)
      @total_metric.hours.should be_an(Array)
      @total_metric.hours.first.should be_a(Hash)
    end
  end

  describe "self.all" do
    before :each do
      Blackbeard::Metric::Total.new("one-total")
      Blackbeard::Metric::Total.new("two-total")
      Blackbeard::Metric::Unique.new("one-unique")
    end
    it "should return a Metric Object for each Metric created" do
      Blackbeard::Metric.all.should have(3).metrics
    end

    it "should instantiate each metric with the correct class" do
      Blackbeard::Metric.all.select{|m| m.id == "two-total"}.should have(1).metric
      Blackbeard::Metric.all.select{|m| m.id == "two-total"}.first.should be_a(Blackbeard::Metric::Total)
    end
  end

end
