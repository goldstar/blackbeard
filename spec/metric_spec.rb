require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Metric do
  let(:metric) { Blackbeard::Metric::Total.new("one-total") }

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
    let(:start_at) { Time.new(2014,1,1,12,0,0) }

    it "should return results for recent hours" do
      metric.recent_hours(3, start_at).should have(3).metric_hours
    end
  end

  describe "recent_days" do
    let(:start_on) { Date.new(2014,1,3) }

    it "shoud return results for recent days" do
      metric.recent_days(3, start_on).should have(3).metric_days
    end
  end

  describe "hour_keys_for_day" do
    it "should return 1 key for every hour from morning to night" do
        keys_for_day = metric.hour_keys_for_day(Date.new(2014,1,1))
        keys_for_day.should have(24).keys
        keys_for_day.first.should == metric.send(:key_for_hour, Time.new(2014,1,1,0,0,0))
        keys_for_day.last.should == metric.send(:key_for_hour, Time.new(2014,1,1,23,0,0))
    end
  end

end
