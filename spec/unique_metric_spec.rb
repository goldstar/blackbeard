require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Metric::Unique do

  let(:metric) { Blackbeard::Metric::Unique.new("join") }
  let(:db) { metric.send(:db) }
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

  # describe "result_for_day" do
  #   let(:date) { Date.new(2014,1,1) }
  #   context "result in db" do
  #     before :each do
  #       day_key = metric.send(:key_for_date, date)
  #       db.set(day_key, 4)
  #     end
  #     it "should return the result from db" do
  #       metric.result_for_day(date).should == 4.0
  #     end
  #     it "should not remerge the results" do
  #       metric.should_not_receive(:generate_result_for_day).with(date)
  #       metric.result_for_day(date)
  #     end
  #   end

  #   context "result in not in db" do
  #     it "should merge hours" do
  #       metric.should_receive(:generate_result_for_day).with(date).and_return(2.0)
  #       metric.result_for_day(date).should == 2.0
  #     end
  #   end
  # end


  describe "generate_result_for_day" do
    let(:date) { Date.new(2014,1,1) }
    before :each do
      key_for_1am = metric.send(:key_for_hour, Time.new(2014,1,1,1))
      db.set_add_member(key_for_1am, '1')
      db.set_add_member(key_for_1am, '2')
      key_for_2pm = metric.send(:key_for_hour, Time.new(2014,1,1,14))
      db.set_add_member(key_for_2pm, '2')
      db.set_add_member(key_for_2pm, '3')
      db.set_add_member(key_for_2pm, '4')
    end

    it "should sum the hours" do
      metric.send(:generate_result_for_day, date).should == 4.0
    end

    it "should store the result if it's not today's result" do
      day_key = metric.send(:key_for_date, date)
      db.should_receive(:set).with(day_key, 4.0)
      metric.send(:generate_result_for_day, date)
    end

  end


end
