require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Metric::Total do

  let(:metric) { Blackbeard::Metric::Total.new("page views") }
  let(:uid) { "unique identifier" }
  let(:ouid) { "other unique identifier" }

  describe "add" do
    it "should create a new metric" do
      expect{
        metric.add(uid, 1)
      }.to change{ Blackbeard::Metric.count }.by(1)
    end

    it "should not create a new metric if it already exists" do
      metric.add(uid, 1)
      expect{
        metric.add(uid, 1)
      }.to_not change{ Blackbeard::Metric.count }
    end

    it "should increment the metric by the amount" do
      expect{
        metric.add(uid, 2)
      }.to change{ metric.result_for_hour(Blackbeard.tz.now) }.by(2)
    end

    it "should increment an existing amount" do
      metric.add(uid, 1)
      expect{
        metric.add(uid, 2)
      }.to change{ metric.result_for_hour(Blackbeard.tz.now) }.from(1).to(3)
    end

    it "should handle negatives ok" do
      metric.add(uid, 2)
      expect{
        metric.add(uid, -1)
      }.to change{ metric.result_for_hour(Blackbeard.tz.now) }.from(2).to(1)
    end

    it "should handle floats" do
      metric.add(uid, 2.5)
      expect{
        metric.add(uid, 1.25)
      }.to change{ metric.result_for_hour(Blackbeard.tz.now) }.to(3.75)
    end
  end



  describe "result_for_hour" do
    it "should return 0 if no metric has been recorded" do
      metric.result_for_hour(Blackbeard.tz.now).should be_zero
    end

    it "should return sum if metric called more than once" do
      metric.add(uid, 2)
      metric.add(uid, 4)
      metric.result_for_hour(Blackbeard.tz.now).should == 6
    end
  end

end
