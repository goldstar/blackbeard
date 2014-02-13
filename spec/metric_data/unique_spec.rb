require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Blackbeard
  module MetricData
    describe Unique do

      let(:metric) { Blackbeard::Metric.new(:unique, "join") }
      let(:metric_data) { metric.metric_data }
      let(:db) { metric.send(:db) }
      let(:uid) { "unique identifier" }
      let(:ouid) { "other unique identifier" }

      describe "add" do
        it "should increment the metric for the uid" do
          expect{
            metric_data.add(uid)
          }.to change{ metric_data.result_for_hour(Blackbeard.tz.now) }.by(1)
        end

        it "should not increment the metric for duplicate uids" do
          metric_data.add(uid)
          expect{
            metric_data.add(uid)
          }.to_not change{ metric_data.result_for_hour(Blackbeard.tz.now) }
        end
      end

      describe "result_for_hour" do
        it "should return 0 if no metric has been recorded" do
          metric_data.result_for_hour(Blackbeard.tz.now).should be_zero
        end

        it "should return 1 if metric called once" do
          metric_data.add(uid)
          metric_data.result_for_hour(Blackbeard.tz.now).should == 1
        end

        it "should return 1 if metric called more than once" do
          3.times{ metric_data.add(uid) }
          metric_data.result_for_hour(Blackbeard.tz.now).should == 1
        end

        it "should return 2 if metric was called with 2 uniques" do
          metric_data.add(uid)
          metric_data.add(ouid)
          metric_data.result_for_hour(Blackbeard.tz.now).should == 2
        end

      end

      describe "generate_result_for_day" do
        let(:date) { Date.new(2014,1,1) }
        before :each do
          key_for_1am = metric_data.send(:key_for_hour, Time.new(2014,1,1,1))
          db.set_add_member(key_for_1am, '1')
          db.set_add_member(key_for_1am, '2')
          key_for_2pm = metric_data.send(:key_for_hour, Time.new(2014,1,1,14))
          db.set_add_member(key_for_2pm, '2')
          db.set_add_member(key_for_2pm, '3')
          db.set_add_member(key_for_2pm, '4')
        end

        it "should sum the hours" do
          metric_data.send(:generate_result_for_day, date).should == 4.0
        end

        it "should store the result if it's not today's result" do
          day_key = metric_data.send(:key_for_date, date)
          db.should_receive(:set).with(day_key, 4.0)
          metric_data.send(:generate_result_for_day, date)
        end

      end
    end
  end

end
