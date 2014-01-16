require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Metric::Unique do

  let(:metric) { Blackbeard::Metric::Unique.new("join") }
  let(:uid) { "unique identifier" }
  let(:ouid) { "other unique identifier" }

  describe "add" do
    it "should create a new metric" do
      expect{
        metric.add(uid)
      }.to change{ Blackbeard::Metric.count }.by(1)
    end

    it "should not create a new metric if it already exists" do
      metric.add(uid)
      expect{
        metric.add(uid)
      }.to_not change{ Blackbeard::Metric.count }
    end

    it "should increment the metric for the uid" do
      expect{
        metric.add(uid)
      }.to change{ metric.result_for_hour(Blackbeard.tz.now) }.by(1)
    end

    it "should not increment the metric for duplicate uids" do
      metric.add(uid)
      expect{
        metric.add(uid)
      }.to_not change{ metric.result_for_hour(Blackbeard.tz.now) }
    end
  end

  describe "result_for_hour" do
    it "should return 0 if no metric has been recorded" do
      metric.result_for_hour(Blackbeard.tz.now).should be_zero
    end

    it "should return 1 if metric called once" do
      metric.add(uid)
      metric.result_for_hour(Blackbeard.tz.now).should == 1
    end

    it "should return 1 if metric called more than once" do
      3.times{ metric.add(uid) }
      metric.result_for_hour(Blackbeard.tz.now).should == 1
    end

    it "should return 2 if metric was called with 2 uniques" do
      metric.add(uid)
      metric.add(ouid)
      metric.result_for_hour(Blackbeard.tz.now).should == 2
    end

  end

end
